## AWS CloudFormation Deployment and Load Balancer Automation

Este proyecto automatiza la creación de infraestructura en AWS mediante CloudFormation y la configura un Load Balancer.

**Scripts**
- deploy.sh:
Crea una infraestructura completa utilizando una plantilla de CloudFormation

**loadbalancer.sh:**
- Registra una instancia EC2 en ejecución en un Load Balancer, verifica su estado hasta que esté InService y realiza un curl para verificar su funcionamiento

**Requisitos**
1. AWS CLI configurado con credenciales válidas (aws configure).
2. Un Key Pair válido en AWS para acceder a la instancia EC2.

### Uso de Scripts
- Script deploy.sh
1. Dale permisos de ejecución a ambos scripts ``` chmod +x deploy.sh loadbalancer.sh ```

Sintaxis

```
./deploy.sh -i <YOUR_IP> -a <AMI_ID> -k <KEY_NAME> -r <REGION> -s <STACK_NAME>
```

Parámetros
-i	Tu IP pública para permitir acceso SSH
-a	ID de la AMI para la instancia EC2.	ami-08eec49a05b603ba3 (es válida)
-k	Nombre del Key Pair creado en AWS (archivo)
-r	Región donde se desplegará la infraestructura.	(us-east-1)
-s	Nombre del stack en CloudFormation.

Si usas ```./deploy.sh -h ``` obtendrás más ayuda con ejemplos

Ejemplo:
```
./deploy.sh -i "127.0.0.0" -a "ami-08eec49a05b603ba3" -k "my_key" -r "us-east-1" -s "test"
```

- Script loadbalancer.sh:
Registra una instancia EC2 en el Load Balancer y verifica su estado

Con el nombre generado al final del primer script se pone el nombre del loadbalancer y la region usada. 
```
./loadbalancer.sh -l <LOAD_BALANCER_NAME> -r <REGION>
```

Parámetros:
-l	Nombre del Load Balancer.	test-LoadBalancer-XYZ
-r	Región del Load Balancer.	us-east-1

- Al final saldrá el curl hecho al load balancer.