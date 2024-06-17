# Projet Devops
# Création de 2 VM ubuntu : vm-ubuntu-install et vm-ubuntu-DevOps
# Nous récupérerons le Dockerfile de l'image fredericeducentre/ubuntu-ssh préalablement préparée avec ssh entre autres.
# y ajouter l'installation de sshpass, docker, Terraform et Ansible
# les 2 VM seront installer dans le même network : ntw_devops pour permettre la communication entre les 2

# Le projet DevOps-CI-CD-Project
# Dans le dossier dockerfile-ubuntu lancer la commande "docker build . -t ubuntu-ssh" pour créer l'image ubuntu-ssh à partir du Dockerfile y présent

# Monter un volume pour faire fonctionner docker sur les vm-ubuntu-install et vm-ubuntu-DevOps
# préciser le montage de volume dans le fichier main.tf ==> voir modules/main.tf dans la ressource docker_container
mounts {
    type   = "bind"
    source = "/var/run/docker.sock"
    target = "/var/run/docker.sock"
  }


# sortir de ce répertoire et se mettre à la racine du projet DevOps-CI-CD-Project et lancer les commandes suivantes pour créer les conteneurs vm-ubuntu-install et vm-ubuntu-DevOps

# initialise le projet
terraform init

# liste les actions qui seront exécutées avec terraform
terraform plan

# exécute les actions configurées dans le fichier main.tf de terraform
terraform apply


# Vérifier que les 2 vm tournent et tester l'accès ssh
# pour vm-ubuntu-install ==>   ssh test@localhost -p 23
# pour vm-ubuntu-DevOps  ==>   ssh test@localhost -p 24


# Dans le conteneur vm-ubuntu-install
# Nous trouverons le code du projet Ansible DevOps-Project-Ansible pour configurer le conteneur vm-ubuntu-DevOps
# dans ce projet, le répertoire /config-vm-ubuntu-devops contient le fichier playbook.yaml pour installer docker, jenkins, sonardb (postgres) et sonnarqube
# le fichier playbook-agent-node.yaml pour installer l'agent node agent_reactjs_node pour le bon fonctionnement d'un projet reactJS
# en occurence l'agent "fredericeducentre/jenkins_agent_node" utilisé pendant les cours
# le fichier inventaire.yaml contient la configuration du serveur (conteneur) vm-ubuntu-DevOps pour accéder en SSH. Ce fichier inventory.yaml est crypté ==> mot de passe vault= secret
# les playbook.yaml et playbook-agent-node.yaml utiliseront ce inventory.yaml crypté

# Sur le conteneur vm-ubuntu-install et dans le dossier /home/test/DevOps-Project-Ansible/config-vm-ubuntu-devops
# lancer la commande suivante pour installer la clé ssh avant d'exécuter le playbook.yaml en précisant l'@IP de vm-ubuntu-devops ==> vérifier l'@IP de votre conteneur par docker inspect vm-ubuntu-devops
sudo ssh test@172.19.0.2 -p 22

# exécuter le playbook.yaml pour installer docker, jenkins, sonnardb et sonnarqube sur vm-ubuntu-devops
sudo ansible-playbook -i inventory.yaml playbook.yaml --ask-become-pass --ask-vault-pass
# become-pass=test
# vault-pass=secret

# Vérifier que l'installation est bien passée sur vm-ubuntu-DevOps
# ========================================================================================================
# Dans contenauer vm-ubuntu-DevOps
# Nous y trouverons installés: 
# docker, jenkins sur le port 8080  sonnarqube sur le port 9000
# Aller se connecter sur jenkins ==> http://localhost:8080/
# Le mot de passe demandé se trouvera dans le fichier /var/*** indiqué du conteneur jenkins_container ou par la commande deocker logs jenkins_container
# renseigner le mot de passe 
# continuer la configuration par : jenkins ==> utilisateur: jenkins - password: jenkins - nom complet: admin jenkins - Email: admin@admin.com
# tester l'exécution d'un pipeline pour confirmer le bon fonctionnement de jenkins
# Si le pipeline stage view n'est pas visible penser à vérifier si le plugin pipeline stage view est installé sinon installer le et redémarrer jenkins

# ========================================================================================================
# Configuer l'agent node sur jenkins
# Aller dans Administrer Jenkins > Nodes > Créer un nouveau node : agent_reactjs_node
# passer le nombre d'exécution sur le node controlleur à 0

# Dans le conteneur vm-ubuntu-install
# Aller dans le répertoire /home/test/DevOps-Project-Ansible/config-vm-ubuntu-devops
# lancer le playbook-agent-node.yaml pour installer l'agent node agent_reactjs_node
sudo ansible-playbook -i inventory.yaml playbook-agent-node.yaml --ask-become-pass --ask-vault-pass
# become-pass=test
# vault-pass=secret

# l'agent jenkins_agent_node sera installé, assurer qu'il soit démarré
# tester l'exécution d'un pipeline en utilisant ce nouveau node avec un projet reactjs

# ========================================================================================================
# Configurer sonnarqube sur http://localhost:9000/ ==> utilisateur: admin password: admin puis changer le password à sonnar
# ========================================================================================================
# maintenant sur jenkins
# ajouter un plugin sonarqube
# Administrer jenkins > system > ajouter plugin sonarqube > redémarrer
# Créer un projet de test sur Sonarqube ==> Test_reactJS
# pour ce projet configurer un token sans utilisateur en local
# le token sera utilisé dans un pipeline comme suit
stage('Scan'){
     steps {
        sh '''
          sonar-scanner \
          -Dsonar.projectKey=Test_reactJS \
          -Dsonar.sources=. \
          -Dsonar.host.url=http://172.24.0.4:9000 \
          -Dsonar.token=sqp_e7e68975f7b6b1ab182072099c1eaaa771f0abb1
        '''
    }
}

# pour l'utilisation de Quality Gate de Sonarqube afin d'appliquer les règles de validation configurer un webhook sur sonarqube qui sera également configuré sur l'installation sonarqube de jenkins
# sur sonarqube configurer un webhook général avec l’url http://@IP:8080/sonarqube-webhook
# aller dans Administration > Configuration > Webhooks
# créer un nouveau webhook avec l'@IP du serveur jenkins (jenkins_container) ==> 172.24.0.2

# Sur le serveur jenkins, aller dans Administrer jenkins > system > chercher la partie de configuration de sonar > ajouter une installation Sonarqube
# Donner un nom à cette installation ==> jenkins_sonarqube
# Utiliser le credential sonar créé précédement ==> dans un secret text
# pas de password, donner un nom à ce crédéntial et attacher le à l'installation sonarqube

# passer un pipeline avec les stages Clone, Test, Build, Scan et Quality Gate
# le pipeline passe et le projet Sonarqube Test_reactJS contiendra les métriques de test

# Delivery de l'image sur hub.docker.com
# préparer un credential pour l'accès au compte hub.docker.com qui réscevra l'image
# préparer le stage Delivery
# faire passer un projet par les stages d'un pipeline
# Clone, Test, Build, Scan, Quality Gate, Delivery
# Vérifier que le push de l'image est bien pasé

