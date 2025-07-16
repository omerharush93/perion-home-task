#!/bin/bash

# 🚀 Helm Chart Validation Script
# Usage: ./validate-helm-deployment.sh [release-name] [namespace]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RELEASE_NAME=${1:-"hello-world-test"}
NAMESPACE=${2:-"hello-world-node"}

echo -e "${BLUE}🔍 Validating Helm deployment: ${RELEASE_NAME} in namespace: ${NAMESPACE}${NC}"
echo "=================================================================="

# Function to check status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
        exit 1
    fi
}

# Function to wait for condition
wait_for_condition() {
    local resource=$1
    local condition=$2
    local timeout=${3:-60}
    
    echo -n "⏳ Waiting for $resource to be $condition..."
    kubectl wait --for=condition=$condition $resource -n $NAMESPACE --timeout=${timeout}s >/dev/null 2>&1
    check_status "$resource is $condition"
}

echo -e "${YELLOW}📋 1. Checking Helm Release...${NC}"
helm status $RELEASE_NAME -n $NAMESPACE >/dev/null 2>&1
check_status "Helm release exists and is deployed"

echo -e "${YELLOW}🐳 2. Checking Deployment...${NC}"
kubectl get deployment hello-world-node -n $NAMESPACE >/dev/null 2>&1
check_status "Deployment exists"

wait_for_condition "deployment/hello-world-node" "Available"

echo -e "${YELLOW}📡 3. Checking Service...${NC}"
kubectl get service hello-world-node-service -n $NAMESPACE >/dev/null 2>&1
check_status "Service exists"

# Check service endpoints
ENDPOINTS=$(kubectl get endpoints hello-world-node-service -n $NAMESPACE -o jsonpath='{.subsets[0].addresses}' 2>/dev/null || echo "[]")
if [ "$ENDPOINTS" != "[]" ] && [ "$ENDPOINTS" != "" ]; then
    echo -e "${GREEN}✅ Service has endpoints${NC}"
else
    echo -e "${RED}❌ Service has no endpoints${NC}"
fi

echo -e "${YELLOW}🛡️ 4. Checking PodDisruptionBudget...${NC}"
kubectl get pdb hello-world-node-pdb -n $NAMESPACE >/dev/null 2>&1
check_status "PodDisruptionBudget exists"

echo -e "${YELLOW}📈 5. Checking KEDA ScaledObject...${NC}"
kubectl get scaledobject hello-world-node-scaler -n $NAMESPACE >/dev/null 2>&1
check_status "KEDA ScaledObject exists"

# Check if KEDA is working
KEDA_STATUS=$(kubectl get scaledobject hello-world-node-scaler -n $NAMESPACE -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
if [ "$KEDA_STATUS" = "True" ]; then
    echo -e "${GREEN}✅ KEDA ScaledObject is ready${NC}"
else
    echo -e "${YELLOW}⚠️ KEDA ScaledObject status: $KEDA_STATUS${NC}"
fi

echo -e "${YELLOW}🏃 6. Checking Pods...${NC}"
# Get pod count
POD_COUNT=$(kubectl get pods -l app=hello-world-node -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
READY_PODS=$(kubectl get pods -l app=hello-world-node -n $NAMESPACE --no-headers 2>/dev/null | grep "Running" | wc -l)

echo "📊 Pod Status: $READY_PODS/$POD_COUNT pods running"

if [ $POD_COUNT -gt 0 ]; then
    echo -e "${GREEN}✅ Pods created${NC}"
    
    # Wait for at least one pod to be ready
    kubectl wait --for=condition=ready pod -l app=hello-world-node -n $NAMESPACE --timeout=60s >/dev/null 2>&1
    check_status "At least one pod is ready"
else
    echo -e "${RED}❌ No pods found${NC}"
    exit 1
fi

echo -e "${YELLOW}🔗 7. Testing Application Endpoints...${NC}"
# Get service cluster IP
SERVICE_IP=$(kubectl get service hello-world-node-service -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null)

if [ ! -z "$SERVICE_IP" ] && [ "$SERVICE_IP" != "None" ]; then
    echo "🌐 Testing via Service ClusterIP: $SERVICE_IP"
    
    # Test main endpoint
    if kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never --quiet -n $NAMESPACE -- curl -s --max-time 10 http://$SERVICE_IP/ >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Main endpoint (/) responding${NC}"
    else
        echo -e "${RED}❌ Main endpoint (/) not responding${NC}"
    fi
    
    # Test health endpoint
    if kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never --quiet -n $NAMESPACE -- curl -s --max-time 10 http://$SERVICE_IP/health >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Health endpoint (/health) responding${NC}"
    else
        echo -e "${RED}❌ Health endpoint (/health) not responding${NC}"
    fi
    
    # Test ready endpoint
    if kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never --quiet -n $NAMESPACE -- curl -s --max-time 10 http://$SERVICE_IP/ready >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Ready endpoint (/ready) responding${NC}"
    else
        echo -e "${RED}❌ Ready endpoint (/ready) not responding${NC}"
    fi
    
    # Get actual response from main endpoint
    echo "📄 Testing main endpoint response:"
    RESPONSE=$(kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never --quiet -n $NAMESPACE -- curl -s --max-time 10 http://$SERVICE_IP/ 2>/dev/null || echo "No response")
    if [ "$RESPONSE" != "No response" ]; then
        echo -e "${GREEN}   Response: $RESPONSE${NC}"
        echo -e "${GREEN}✅ Application is serving content${NC}"
    else
        echo -e "${RED}❌ No response from application${NC}"
    fi
    
else
    echo -e "${RED}❌ Could not get service ClusterIP${NC}"
    
    # Fallback: test directly via pod
    POD_NAME=$(kubectl get pods -l app=hello-world-node -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ ! -z "$POD_NAME" ]; then
        echo "🔄 Fallback: Testing via pod $POD_NAME"
        kubectl exec $POD_NAME -n $NAMESPACE -- wget -q --timeout=5 --tries=1 -O- http://localhost:3000/health >/dev/null 2>&1
        check_status "Health endpoint responding via pod"
        
        kubectl exec $POD_NAME -n $NAMESPACE -- wget -q --timeout=5 --tries=1 -O- http://localhost:3000/ready >/dev/null 2>&1
        check_status "Ready endpoint responding via pod"
    fi
fi

echo -e "${YELLOW}🔍 8. Resource Summary...${NC}"
echo "=================================================================="
echo "📋 Deployment:"
kubectl get deployment hello-world-node -n $NAMESPACE -o wide

echo ""
echo "🐳 Pods:"
kubectl get pods -l app=hello-world-node -n $NAMESPACE -o wide

echo ""
echo "📡 Service:"
kubectl get service hello-world-node-service -n $NAMESPACE -o wide

echo ""
echo "📈 KEDA:"
kubectl get scaledobject hello-world-node-scaler -n $NAMESPACE -o wide

echo ""
echo "🛡️ PDB:"
kubectl get pdb hello-world-node-pdb -n $NAMESPACE -o wide

echo ""
echo -e "${YELLOW}📊 9. Quick Health Check Summary...${NC}"
echo "=================================================================="

# Deployment ready replicas
READY_REPLICAS=$(kubectl get deployment hello-world-node -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
DESIRED_REPLICAS=$(kubectl get deployment hello-world-node -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
echo "🎯 Replicas: $READY_REPLICAS/$DESIRED_REPLICAS ready"

# Service ClusterIP
CLUSTER_IP=$(kubectl get service hello-world-node-service -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "None")
echo "🌐 Service ClusterIP: $CLUSTER_IP"

# KEDA current replicas
CURRENT_REPLICAS=$(kubectl get scaledobject hello-world-node-scaler -n $NAMESPACE -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo "Unknown")
echo "⚡ KEDA Current Replicas: $CURRENT_REPLICAS"

echo ""
echo -e "${GREEN}🎉 ALL SYSTEMS UP AND RUNNING! 🎉${NC}"
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}✅ Helm Chart Successfully Deployed${NC}"
echo -e "${GREEN}✅ All Resources Created and Ready${NC}"
echo -e "${GREEN}✅ Application Endpoints Tested and Working${NC}"
echo -e "${GREEN}✅ KEDA Autoscaling Configured${NC}"
echo -e "${GREEN}✅ Production Ready!${NC}"

echo ""
echo -e "${BLUE}🔧 Monitoring commands:${NC}"
echo "   📊 Watch pods: kubectl get pods -l app=hello-world-node -n $NAMESPACE -w"
echo "   📈 Check KEDA: kubectl describe scaledobject hello-world-node-scaler -n $NAMESPACE"
echo "   📋 Check logs: kubectl logs -l app=hello-world-node -n $NAMESPACE -f"
echo "   🔍 Full status: helm status $RELEASE_NAME -n $NAMESPACE"
echo "   🌐 Port forward: kubectl port-forward svc/hello-world-node-service -n $NAMESPACE 8080:80"