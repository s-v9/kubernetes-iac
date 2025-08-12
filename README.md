# Challenge: Provisioning Kubernetes Cluster with Infrastructure as Code

## Scopo e descrizione della soluzione

Strumenti utilizzati:

- **Vagrant** per la creazione delle VM  
- **Ansible** per l’installazione di K3s  
- **Terraform** per la gestione delle risorse Kubernetes  
- **Helm** per il deployment dell’applicazione  
- **GitHub Actions** per la pipeline CI  

---

## Provisioning del cluster Kubernetes
Cluster creato utilizzando Vagrant e ansible

Nel particolare si è utilizzato [k3s-ansible](https://github.com/k3s-io/k3s-ansible), che include:

- `Vagrantfile` per generare le VM  
- Playbook Ansible per installare K3s

Vagrant è stato scelto in quanto ci permette di mantenere una struttura
Iac anche per la creazione delle VM

K3s è stato scelto principamente per ridurre il consumo di risorse. Inoltre non necessitiamo di un datastore etcd, 
default per K8s, in quanto è presente un solo server node.
### Modifiche apportate:

### Vagrantfile

- Cambiato il numero di VM per rispettare i requisiti (3 nodi: 1 server, 2 worker)  
- Modificata modalità di provisioning da Ansible a `ansible_local` per compatibilità Windows  

### Ansible playbook

- Task aggiuntiva su role server per esportare il file `kubeconfig`, necessario per accesso al cluster via Terraform  


---

## Provisioning con Terraform e benchmark di sicurezza

Terraform:

- Configurazione dei provider Helm e Kubernetes  
- Creazione del namespace `kiratech-test`  
- Esecuzione del benchmark di sicurezza CIS con [kube-bench](https://github.com/aquasecurity/kube-bench), tramite manifest Kubernetes  
- Il manifest è stato configurato per essere eseguito sul node server, in quanto necessario al benchmark per eseguire correttamente i controlli  

---

## Deployment dell’applicazione Helm

Applicazione scelta: **[Kubetail](https://github.com/kubetail-org/kubetail)**

Kubetail è una dashboard di logging in tempo reale per Kubernetes che permette di visualizzare i log delle risorse tramite un'interfaccia web. 
È composta da diversi servizi: i Cluster Agent, presenti su ogni nodo, raccolgono informazioni locali e le inviano al servizio Cluster API, 
che le elabora e le rende disponibili al servizio Dashboard, responsabile della visualizzazione dei dati.
- Il deployment è stato effettuato tramite il provider Helm di Terraform, utilizzando l'Helm chart fornita da Kubetail
- Il deployment è stato effettuato nel namespace `kiratech-test` creato in precedenza
- La strategia di update `rollingUpdate` è già configurata nell'Helm chart fornita, quindi non sono state necessarie modifiche  
- È stato aggiunto il deploy di un servizio `NodePort` per accesso alla webpage  

La webpage è resa disponibile in locale  e ci permette di visualizzare direttamente i log del benchmark di sicurezza

---

## Pipeline di Continuous Integration

La pipeline CI è stata implementata con GitHub Actions, configurata per eseguire linting solo sui percorsi rilevanti in caso di `push` o `pull_request` su quei percorsi.

### Linting tools

| Tecnologia | Tool             | Link                                                                 |
|------------|------------------|----------------------------------------------------------------------|
| Terraform  | `tflint`         | [terraform-linters/tflint](https://github.com/terraform-linters/tflint) |
| Ansible    | `ansible-lint`   | [ansible/ansible-lint](https://github.com/ansible/ansible-lint)         |
| Helm       | `chart-testing`  | [helm/chart-testing-action](https://github.com/helm/chart-testing-action) |

---

 Copiare la repository
```bash
git clone <repository-url>
cd <repository-folder>
```
Avviare vagrant per creare le vm e eseguire il playbook ansible
```bash
cd ansible
vagrant up
```
Attendere la creazione delle VM e installazione di k3s
Modificare il config file generato in kubernetes-iac\ansible con l'ip del server.
Nel nostro caso 10.10.10.100
```bash
- cluster:
    certificate-authority-data: 
    server: https://10.10.10.100:6443
```
```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```
Il cluster è ora configurato e Kubetail è accessibile in locale a http://10.10.10.100:30080/