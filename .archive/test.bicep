module blueprint '../app-blueprint.bicep' = {
  name: 'my-app'
  params: {
    imageName: 'nginxdemos/hello'
    tag: 'latest'
  }
}

output url string = blueprint.outputs.fqdn
