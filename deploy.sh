#!/bin/bash

function show_help {
    echo "Uso: $0 -i <YOUR_IP> -a <AMI_ID> -k <KEY_NAME> -r <REGION> -s <STACK_NAME>"
    echo ""
    echo "Opciones:"
    echo "  -i    Tu IP publica (ej. 192.168.1.1)"
    echo "  -a    ID de la AMI (ej. ami-08eec49a05b603ba3)"
    echo "  -k    Nombre del Key Pair (ej. lab3)"
    echo "  -r    Región de AWS (ej. us-east-1)"
    echo "  -s    Nombre del Stack (ej. test)"
    echo ""
    exit 1
}

# Parsear las opciones (flags)
while getopts "i:a:k:r:s:h" opt; do
    case ${opt} in
        i) YOUR_IP=${OPTARG} ;;
        a) AMI_ID=${OPTARG} ;;
        k) KEY_NAME=${OPTARG} ;;
        r) REGION=${OPTARG} ;;
        s) STACK_NAME=${OPTARG} ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

# Verifica que todas las variables se pasaron
if [ -z "$YOUR_IP" ] || [ -z "$AMI_ID" ] || [ -z "$KEY_NAME" ] || [ -z "$REGION" ] || [ -z "$STACK_NAME" ]; then
    echo "Error: flags obligatorias"
    show_help
fi

# Reemplaza variables en el archivo YAML
cp template_qualentum.yaml infraestructura-temp.yaml
sed -i "s#\${YOUR_IP}#$YOUR_IP#g" infraestructura-temp.yaml
sed -i "s#\${AMI_ID}#$AMI_ID#g" infraestructura-temp.yaml
sed -i "s#\${KEY_NAME}#$KEY_NAME#g" infraestructura-temp.yaml

# Valida la plantilla
echo "Validando la plantilla CloudFormation..."
aws cloudformation validate-template --template-body file://infraestructura-temp.yaml
if [ $? -ne 0 ]; then
    echo "Error: la validacion falla."
    exit 1
fi

# Desplega el stack
echo "Desplegando el stack en AWS..."
aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://infraestructura-temp.yaml --region $REGION

# Esperar a que el stack se complete
echo "Esperando a que el stack se despliegue..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME --region $REGION
echo "Stack creado exitosamente."

echo "Obteniendo el nombre del Load Balancer..."
LOAD_BALANCER_NAME=$(aws elb describe-load-balancers --region $REGION \
    --query "LoadBalancerDescriptions[?contains(DNSName, '$STACK_NAME')].LoadBalancerName" \
    --output text)

# elimina archivo temp
rm infraestructura-temp.yaml