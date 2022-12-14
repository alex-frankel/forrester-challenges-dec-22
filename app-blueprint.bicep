// deploy a simple container apps 
// with specific image

param location string = resourceGroup().location

param imageName string
param tag string

// optional for dockerhub
param registryUrl string = 'docker.io'
param port int = 80
// param userName string = ''
// @secure()
// param password string = ''

param isExternal bool = true

var image = '${registryUrl}/${imageName}:${tag}'

// instantiate the environment
module env 'modules/managed-environment.bicep' = {
  name: 'envDeploy'
  params: {
    baseName: 'forresterChallenge'
    location: location
  }
}

// create one app
module app 'modules/http-container.bicep' = {
  name: 'appDeploy'
  params: {
    location: location
    containerAppName: 'my-app'
    containerImage: image
    containerPort: port
    // containerRegistry: registryUrl
    // containerRegistryPassword: userName
    // containerRegistryUsername: password
    environmentId: env.outputs.environmentId
    isExternalIngress: isExternal
  }
}

output fqdn string = app.outputs.fqdn
