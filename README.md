# Basic-magento-setup-using-Kubernetes-cluster
```
Magento2-Kubernetes-Deployment/
│
├── README.md
├── docs/
│   ├── 01-Prerequisites.md
│   ├── 02-Namespace.md
│   ├── 03-Persistent-Volumes.md
│   ├── 04-MySQL.md
│   ├── 05-Redis.md
│   ├── 06-OpenSearch.md
│   ├── 07-PHP-FPM.md
│   ├── 08-Nginx.md
│   ├── 09-Magento-Installation.md
│   ├── 10-Static-Content-Issue.md
│   ├── 11-Ingress-Setup.md
│   ├── 12-Ingress-502-Troubleshooting.md
│   ├── 13-Production-Mode.md
│   ├── 14-Verification.md
│   └── 15-Interview-Questions.md
│
├── kubernetes/
│   ├── namespace.yml
│   ├── pvc.yml
│   ├── mysql-secret.yml
│   ├── mysql.yml
│   ├── redis.yml
│   ├── opensearch.yml
│   ├── php-fpm.yml
│   ├── nginx-configmap.yml
│   ├── nginx.yml
│   ├── ingress.yml
│   └── varnish.yml
│
└── screenshots/
```




**1. Project Overview**
   # Magento 2 on Kubernetes

This project demonstrates deploying Magento 2 on Kubernetes using:

- Nginx
- PHP-FPM
- MariaDB/MySQL
- Redis
- OpenSearch
- Persistent Volumes
- NGINX Ingress Controller

Environment:
- Kubernetes v1.34
- Docker Desktop Kubernetes
- macOS
**2. Architecture Diagram**
```
Browser
   |
Ingress
   |
Nginx Service
   |
Nginx Pod
   |
PHP-FPM Service
   |
PHP-FPM Pod
   |
---------------------------------
| MySQL | Redis | OpenSearch |
---------------------------------
```
**3. Namespace Creation**
File:
magento-namespace.yml


Commands:
kubectl apply -f magento-namespace.yml
kubectl get ns

Verification:
kubectl get ns magento

**4. Shared Storage**

File:
magento-shared-pvc.yml

Purpose:

Used by:
- PHP-FPM Pod
- Nginx Pod
Shared Magento codebase

Verification:
kubectl get pvc -n magento

**5. MySQL Deployment**

File:
mysql-secret.yml
mysql.yml

Deploy:
kubectl apply -f mysql-secret.yml
kubectl apply -f mysql.yml

Verify:
kubectl get pods -n magento
kubectl logs deploy/mysql -n magento

**6. Redis Deployment**

File:
redis.yml

Deploy:
kubectl apply -f redis.yml

Verify:

kubectl get pods -n magento

**7. OpenSearch Deployment**

File:
opensearch.yml

Deploy:
kubectl apply -f opensearch.yml

Verify:
kubectl logs deploy/opensearch -n magento

**8. PHP-FPM Deployment**

File:
php-fpm.yml

Deploy:
kubectl apply -f php-fpm.yml

Verify:
kubectl get svc php-fpm -n magento

**9. Nginx Deployment**

File:
nginx-configmap.yml
nginx.yml

Deploy:
kubectl apply -f nginx-configmap.yml
kubectl apply -f nginx.yml

Verify:
kubectl exec -it deploy/nginx -n magento -- sh

**10. Magento Installation**
kubectl exec -it deploy/php-fpm -n magento -- sh
```
Install:
php bin/magento setup:install \
--base-url=http://localhost:8080 \
--db-host=mysql \
--db-name=magento \
--db-user=root \
--db-password=password \
--backend-frontname=admin \
--admin-firstname=Admin \
--admin-lastname=User \
--admin-email=admin@example.com \
--admin-user=admin \
--admin-password=Admin123@ \
--language=en_US \
--currency=USD \
--timezone=UTC \
--use-rewrites=1
```
**11. Port Forward Testing**
kubectl port-forward svc/nginx 8080:80 -n magento

Access:
http://localhost:8080

**12. Static Content Issue**

Problem:
styles-m.css -> 404
require.js -> 404

Symptoms:
Page loaded without CSS
Root Cause:
Missing Magento static version rewrite
Fix:
```
location ~ ^/static/version {
rewrite ^/static/(version\d*/)?(.*)$ /static/$2 last;
}
```
Verification:
styles-m.css -> 200
require.js -> 200

**13. Production Mode**
php bin/magento deploy:mode:set production

Deploy static:
php bin/magento setup:static-content:deploy -f

Verify:
find pub/static -type f | wc -l

**14. Ingress Installation**

Install:
kubectl apply -f ingress-nginx-controller.yaml

Verify:
kubectl get pods -n ingress-nginx

**15. Ingress Configuration**

File:
magento-ingress.yml

Host:
host: magento.local

Apply:
kubectl apply -f magento-ingress.yml

**16. Hosts File**
sudo vi /etc/hosts
Add:
127.0.0.1 magento.local
Verify:
ping magento.local

**17. Ingress 502 Issue**

Problem:
502 Bad Gateway
Root Cause:
upstream sent too big header
Ingress Logs:
kubectl logs deploy/ingress-nginx-controller -n ingress-nginx
Error:

upstream sent too big header

Fix:
annotations:
  nginx.ingress.kubernetes.io/proxy-buffer-size: "128k"
  nginx.ingress.kubernetes.io/proxy-buffers-number: "8"
  nginx.ingress.kubernetes.io/proxy-busy-buffers-size: "256k"
  
**18. Local Nginx Conflict**

Problem:
curl http://magento.local

returned:
502 Bad Gateway

Check:
sudo lsof -iTCP:80 -sTCP:LISTEN -n -P
Found:
nginx

Fix:
sudo nginx -s stop

Verification:
curl http://magento.local -I

returns:
HTTP/1.1 200 OK

**19. Final Verification**
kubectl get pods -n magento
kubectl get svc -n magento
kubectl get ingress -n magento

Verify:
curl http://magento.local -I

Expected:
HTTP/1.1 200 OK

**20. Interview Questions Section**

Include:
Why PHP-FPM?
Why Nginx?
Why Redis?
Why OpenSearch?
Why PVC?
Why Ingress?
Difference Between Service and Ingress?
How did you troubleshoot 404 static content?
How did you troubleshoot 502 Bad Gateway?
How did you troubleshoot Ingress issues?


















