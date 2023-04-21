# Chapter Three of CKS Course

## Notes

### RuntimeClass

Allows multiple runtimes to be installed to be and declared in the pod spec.

### Container Runtimes

- gVisor
- Kata
- PouchContainer
- Firecracker
- UniK: 
 
Different than container runtime interfaces like cri-o and containerd


## Tools

- Trow: Open source registry and image management tool.
- Prisma Cloud: comprehensive cloud secuirty platform for multi- and hybrid-
  cloud environments
- NeuVector: Kubernetes-native container security platform providing deep packet
  inspection and a focus on containers firewalls. Also, it constantly monitors
  CVEs to push out updates for new vulnerabilities.
- Clair: Static analysis tool for vulnerabilities in application containers; it
  does not require the image to be run to scan. Compares manifests to common 
  registries and checks for vulnerabilities.
- Aqua: Complete enterprise-wide security solution claiming full container
  lifecycle security via scanning and heuristic tools. Take a look at Trivy
- Notary: CNCF project aimed at publishing any data and verifying the content
  using keys such as TLS to ensure the data is unchanged. Based on TUF framework
- Harbor: CNCF project to provide secure registry and manage artifacts for cloud
  native platforms and Docker. 

### Grafeas

Stores structured metadata about an object in a flexible and easy to query
manner. 

- Voucher: Checks images after build and ensures the image has not changed upon
  deployment/
- Kritis: Uses Voucher and Grafeas information to allow or deny the usage of an
  image in the cluster.

### GVisor

Go-written sandbox often used with SELinux or seccomp. idependent kernel 
between the host and the containerized application. 
runsc runtime is the binary entry point to run app inside sandbox.

two process run inside gvisor

1. Sentry: Handles all of the kernel functionailty the container requires.
  Similar to the kernel of the application. 
2. Handles access to the filesysten, and runs in a restricted seccomp container

### Kata

Leverages hardware virtualization, to provide per-container kernels.
Works with Docker and cri-o architectures. 

