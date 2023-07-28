@description('Specifies the location for resources.')
param location string = 'eastus'
@minLength(3)
@maxLength(19)
@description('Name of the Storage Account with prefix')
param StgNamePrefix string
@allowed(['Standard_LRS'
'Standard_ZRS'
'Standard_GRS'
'Standard_RAGRS'
'Premium_LRS'
'Premium_ZRS'
'Standard_GZRS'
'Standard_RAGZRS'
])

param StgSKU string = 'Standard_LRS'
param StgTags object = {
  Environment:'Dev'
  }
  //var StgName='$ {StgNamePrefix}${take (uniqueString(resourceGroup().id,5)}'
  var UniqueID= uniqueString(resourceGroup().id)
  var UniqueIDshort=take(UniqueID,5)
  var StgName='${StgNamePrefix}${UniqueIDshort}'
 

resource createStorage 'Microsoft.Storage/storageAccounts@2022-09-01' ={
  name:StgName
  location: location
  sku: {
    name: StgSKU
  }
  kind: 'StorageV2'
  tags:StgTags
 
}
