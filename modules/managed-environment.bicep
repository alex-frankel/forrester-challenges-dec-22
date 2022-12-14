param location string = resourceGroup().location
param baseName string

var logAnalyticsWorkspaceName = '${baseName}-logs'

// LA workspace required...
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: '${baseName}-environment'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }

  resource stgEnv 'storages' = {
    name: 'envstorage'
    properties: {
      azureFile: {
        accountName: stg.name
        accountKey: stg.listKeys().keys[0].value
        shareName: stg::fileServices::shares.name
        accessMode: 'ReadWrite'
      }
    }
  }
}

resource stg 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'envfiles${uniqueString(resourceGroup().id, 'forrester')}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource fileServices 'fileServices' = {
    name: 'default'

    resource shares 'shares' = {
      name: 'envfileshare'
    }
  }
}

output environmentId string = environment.id
