#!/bin/bash


# flags
while getopts "l:r:h" opt; do
    case ${opt} in
        l) LOAD_BALANCER_NAME=${OPTARG} ;;
        r) REGION=${OPTARG} ;;
        h) show_help ;;
        *) show_help ;;
    esac
done

# verificacion
if [ -z "$LOAD_BALANCER_NAME" ] || [ -z "$REGION" ]; then
    echo "Error: flags obligatorias."
    show_help
fi

# instancia running
INSTANCE_ID=$(aws ec2 describe-instances --region $REGION \
    --query "Reservations[*].Instances[?State.Name=='running'].InstanceId" \
    --output text)

if [ -z "$INSTANCE_ID" ]; then
    echo "No se encontraron instancias en estado 'running'."
    exit 1
fi
echo "Instancia encontrada: $INSTANCE_ID"

# set de la instancia en el loadbal
aws elb register-instances-with-load-balancer \
    --load-balancer-name $LOAD_BALANCER_NAME \
    --instances $INSTANCE_ID \
    --region $REGION

# wait
while true; do
    STATE=$(aws elb describe-instance-health \
        --load-balancer-name $LOAD_BALANCER_NAME \
        --region $REGION \
        --query "InstanceStates[?InstanceId=='$INSTANCE_ID'].State" \
        --output text)

    if [ "$STATE" == "InService" ]; then
        echo "Instancia en estado 'InService'."
        break
    else
        echo "Estado actual: $STATE. Esperando..."
        sleep 5
    fi
done

# DNS
echo "Obteniendo el DNS del Load Balancer"
DNS_NAME=$(aws elb describe-load-balancers \
    --region $REGION \
    --query "LoadBalancerDescriptions[?LoadBalancerName=='$LOAD_BALANCER_NAME'].DNSName" \
    --output text)

if [ -z "$DNS_NAME" ]; then
    echo "No se pudo obtener el DNS del Load Balancer."
    exit 1
fi
echo "DNS del Load Balancer: $DNS_NAME"

echo "Ejecuto curl al Load Balancer"
curl http://$DNS_NAME:8080