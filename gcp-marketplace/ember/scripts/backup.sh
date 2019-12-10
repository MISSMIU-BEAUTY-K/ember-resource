#!/bin/bash
#
# Copyright 2018 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [[ -z "$1" ]]; then
  echo "Please, provide app instance name"
  echo "Invoke the script in the following way:"
  echo "$0 <app instance name> <namespace> <backup folder> <mongo username> <mongo password>"
  exit 1
fi

if [[ -z "$2" ]]; then
  echo "Please, provide Kubernetes namespace to use"
  echo "Invoke the script in the following way:"
  echo "$0 <app instance name> <namespace> <backup folder> <mongo username> <mongo password>"
  exit 1
fi

if [[ -z "$3" ]]; then
  echo "Please, provide folder for backup"
  echo "Invoke the script in the following way:"
  echo "$0 <app instance name> <namespace> <backup folder> <mongo username> <mongo password>"
  exit 1
fi

if [[ -z "$4" ]]; then
  echo "Please, provide mongo username"
  echo "Invoke the script in the following way:"
  echo "$0 <app instance name> <namespace> <backup folder> <mongo username> <mongo password>"
  exit 1
fi

if [[ -z "$5" ]]; then
  echo "Please, provide mongo password"
  echo "Invoke the script in the following way:"
  echo "$0 <app instance name> <namespace> <backup folder> <mongo username> <mongo password>"
  exit 1
fi

APP_INSTANCE="$1"
NAMESPACE="$2"
MONGODB_BACKUP_DIR="$3"
MONGO_USERNAME="$4"
MONGO_PASSWORD="$5"

echo "Connecting to the following Ember application: APP_INSTANCE..."

echo "Connecting to Ember MongoDB instance and creating a temporary backup directory"
kubectl exec "${APP_INSTANCE}-mongodb-0" --namespace $NAMESPACE -- mkdir -p /$MONGODB_BACKUP
echo "Connecting to MongoDB instance and making a backup"
kubectl exec "${APP_INSTANCE}-mongodb-0" --namespace $NAMESPACE -- mongodump -u "$MONGO_USERNAME" -p "MONGO_PASSWORD" --authenticationDatabase=admin --out=/$MONGODB_BACKUP
echo "Creating backup directory on local computer"
mkdir -p $MONGODB_BACKUP
echo "Copying backup to local computer"
kubectl cp ${APP_INSTANCE}-mongodb-0:/$MONGODB_BACKUP $MONGODB_BACKUP
echo "Backup operation finished."