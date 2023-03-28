# Security

## Things that might be useful later

### RBAC

Three subjects: User, Service Accounts, Groups (CluserRoleBindings)

1. Summary of RBAC process:
    - Determine or create namespace
    - Create certificate credentials for user
    - Set the credentials for the user to the namespace using a context
    - Create a role for the expected task set
    - Bind the user to the role
    - Verify the user has limited access

### Webhook

http callback; simple event-notification via HTTP POST. A web application 
implementing webhooks will POST a message to a URL when certain things happen.

### Security Contexts

```yaml
spec:
  securityContext:
    runAsNonRoot: true
```

## Labs

1. create certificate
 
> openssl genrsa -out DevDan.key 2048
> openssl req -new -key DevDan.key -out DevDan.csr -subj "/CN=DevDan/O=development"
> openssl x509 -req -in DevDan.csr \
> -CA /etc/kubernetes/pki/ca.crt \
> -CAkey /etc/kubernetes/pki/ca.key
> -CAcreateserial \
> -out DevDan.crt -days 45

1. set credentials

> kubectl config set-credentials DevDan \
> --cleint-certificate=/home/student/DevDan.crt \
> --client-key=/home/student/DevDan.key

1. set context

> kubectl config set-context DevDan-context \
> --cluster=kubernetes \
> --namespace=development \
> --user=DevDan




