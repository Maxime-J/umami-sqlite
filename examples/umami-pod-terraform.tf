# =============================================================================
# k8s setup with traefik ingress, cert manager, network policies and pvc
# =============================================================================

# -----------------------------------------------------------------------------
# VARIABLES
# -----------------------------------------------------------------------------

variable "umami_domain" {
  description = "Domain used to access Umami"
  type        = string
}

variable "pvc_storage_class" {
  description = "PVC Storage Class (e.g.: hcloud-volumes on Hetzner)"
  type        = string
}

# -----------------------------------------------------------------------------
# NAMESPACE
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "ns_umami" {
  depends_on = [null_resource.fetch_kubeconfig]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: umami
  YAML
}

# -----------------------------------------------------------------------------
# APP SECRET
# -----------------------------------------------------------------------------

resource "random_password" "umami_app_secret" {
  length  = 64
  special = false
}

resource "kubectl_manifest" "umami_secret" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: umami-secret
      namespace: umami
    type: Opaque
    stringData:
      APP_SECRET: "${random_password.umami_app_secret.result}"
  YAML
}

# -----------------------------------------------------------------------------
# PERSISTENT VOLUME CLAIM
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "umami_pvc" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: umami-data
      namespace: umami
    spec:
      accessModes:
        - ReadWriteOnce
      storageClassName: ${var.pvc_storage_class}
      resources:
        requests:
          storage: 1Gi
  YAML
}

# -----------------------------------------------------------------------------
# DEPLOYMENT
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "umami_app" {
  depends_on = [
    kubectl_manifest.ns_umami,
    kubectl_manifest.umami_pvc,
    kubectl_manifest.umami_secret
  ]
  server_side_apply = true
  yaml_body         = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: umami
      namespace: umami
      labels:
        app: umami
    spec:
      replicas: 1
      strategy:
        type: Recreate
      selector:
        matchLabels:
          app: umami
      template:
        metadata:
          labels:
            app: umami
        spec:
          enableServiceLinks: false
          securityContext:
            fsGroup: 1000
          containers:
            - name: umami
              image: ghcr.io/maxime-j/umami-sqlite:latest
              env:
                - name: DATABASE_URL
                  value: "file:/db/umami.db"
                - name: APP_SECRET
                  valueFrom:
                    secretKeyRef:
                      name: umami-secret
                      key: APP_SECRET
              ports:
                - containerPort: 3000
                  name: http
              volumeMounts:
                - name: data
                  mountPath: /db
              resources:
                requests:
                  memory: "128Mi"
                  cpu: "100m"
                limits:
                  memory: "512Mi"
                  cpu: "500m"
              livenessProbe:
                tcpSocket:
                  port: 3000
                initialDelaySeconds: 30
                periodSeconds: 30
                timeoutSeconds: 5
                failureThreshold: 3
              readinessProbe:
                tcpSocket:
                  port: 3000
                initialDelaySeconds: 10
                periodSeconds: 15
                timeoutSeconds: 3
                failureThreshold: 3
          volumes:
            - name: data
              persistentVolumeClaim:
                claimName: umami-data
  YAML
}

# -----------------------------------------------------------------------------
# SERVICE
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "umami_service" {
  depends_on        = [kubectl_manifest.umami_app]
  server_side_apply = true
  yaml_body         = <<-YAML
    apiVersion: v1
    kind: Service
    metadata:
      name: umami-svc
      namespace: umami
      labels:
        app: umami
    spec:
      selector:
        app: umami
      ports:
        - name: http
          port: 80
          targetPort: 3000
  YAML
}

# -----------------------------------------------------------------------------
# INGRESS
# -----------------------------------------------------------------------------

resource "kubectl_manifest" "umami_ingress" {
  depends_on        = [kubectl_manifest.umami_service]
  server_side_apply = true
  yaml_body         = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: umami
      namespace: umami
      annotations:
        cert-manager.io/cluster-issuer: "letsencrypt-prod"
        traefik.ingress.kubernetes.io/router.entrypoints: websecure
    spec:
      ingressClassName: traefik
      tls:
        - hosts:
            - ${var.umami_domain}
          secretName: umami-tls
      rules:
        - host: ${var.umami_domain}
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: umami-svc
                    port:
                      number: 80
  YAML
}

# -----------------------------------------------------------------------------
# NETWORK POLICIES
# -----------------------------------------------------------------------------

# Default deny all traffic
resource "kubectl_manifest" "netpol_deny_all_umami" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: default-deny-all
      namespace: umami
    spec:
      podSelector: {}
      policyTypes:
        - Ingress
        - Egress
  YAML
}

# Allow DNS egress
resource "kubectl_manifest" "netpol_dns_umami" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-dns
      namespace: umami
    spec:
      podSelector: {}
      policyTypes:
        - Egress
      egress:
        - to:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: kube-system
          ports:
            - port: 53
              protocol: UDP
            - port: 53
              protocol: TCP
  YAML
}

# Allow Traefik ingress
resource "kubectl_manifest" "netpol_traefik_to_umami" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-traefik-ingress
      namespace: umami
    spec:
      podSelector:
        matchLabels:
          app: umami
      policyTypes:
        - Ingress
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: kube-system
              podSelector:
                matchLabels:
                  app.kubernetes.io/name: traefik
          ports:
            - port: 3000
              protocol: TCP
  YAML
}

# Allow Traefik to reach cert-manager ACME HTTP-01 solver pods
resource "kubectl_manifest" "netpol_umami_traefik_to_acme_solver" {
  depends_on = [kubectl_manifest.ns_umami]

  yaml_body = <<-YAML
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: allow-traefik-to-acme-solver
      namespace: umami
    spec:
      podSelector:
        matchLabels:
          acme.cert-manager.io/http01-solver: "true"
      policyTypes:
        - Ingress
      ingress:
        - from:
            - namespaceSelector:
                matchLabels:
                  kubernetes.io/metadata.name: kube-system
              podSelector:
                matchLabels:
                  app.kubernetes.io/name: traefik
          ports:
            - port: 8089
              protocol: TCP
  YAML
}
