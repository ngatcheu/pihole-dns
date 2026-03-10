# Pi-hole DNS Server

Déploiement automatisé de Pi-hole via Ansible pour le homelab.

## Prérequis

- Une VM Debian/Ubuntu ou RHEL/Rocky avec accès SSH
- Ansible installé sur la machine de contrôle

## Structure

```
pi-hole/
├── inventory.yml          # Inventaire des serveurs DNS
├── playbook.yml           # Playbook de déploiement
└── README.md
```

## Configuration

### Inventaire

Modifier `inventory.yml` avec l'IP de votre serveur Pi-hole :

```yaml
pihole01:
  ansible_host: 192.168.1.119
  ansible_user: root
```

### Variables principales

| Variable | Description | Défaut |
|----------|-------------|--------|
| `pihole_password` | Mot de passe admin | `change123` |
| `dns_records` | Enregistrements DNS personnalisés | - |

## Déploiement

```bash
cd dns/pi-hole
ansible-playbook -i inventory.yml playbook.yml
```

## Interface Web

Après déploiement, accéder à l'interface Pi-hole :

```
http://192.168.1.119/admin
```

Mot de passe : `change123`

## Ajouter des entrées DNS

Pour ajouter de nouvelles entrées DNS locales, modifier `dns_records` dans `playbook.yml` :

```yaml
dns_records:
  - host: 'rancher.homelab.local'
    ip: '192.168.1.200'
  - host: 'grafana.homelab.local'
    ip: '192.168.1.200'
```

Puis relancer le playbook :

```bash
ansible-playbook -i inventory.yml playbook.yml
```

## Utilisation avec le Homelab

Pi-hole est configuré pour résoudre les noms des services Kubernetes exposés via MetalLB :

| Service | Hostname | IP MetalLB |
|---------|----------|------------|
| Rancher | rancher.homelab.local | 192.168.1.200 |

Pour que vos machines utilisent Pi-hole comme DNS :
1. Configurer Pi-hole comme DNS dans votre box/routeur
2. Ou configurer manuellement le DNS sur chaque machine (192.168.1.119)
