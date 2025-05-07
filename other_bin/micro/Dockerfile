# Étape 1 : Build Micro sur Rocky Linux
FROM rockylinux:8

# Installer les dépendances
RUN dnf install -y git make golang tar

# Définir le dossier de travail
WORKDIR /build

# Cloner le dépôt Micro
RUN git clone https://github.com/zyedidia/micro.git

WORKDIR /build/micro

# Compiler Micro
RUN make

# Étape 2 : Créer une image minimale (optionnel si tu veux une image Docker pour exécuter Micro)
# FROM rockylinux:8
# COPY --from=builder /build/micro/micro /usr/local/bin/micro
# ENTRYPOINT [ "micro" ]

# Pour export local : copier le binaire compilé
# Utilise ce chemin : /build/micro/micro
