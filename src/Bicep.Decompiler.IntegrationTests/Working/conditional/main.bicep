param something string = 'value'
param location string = resourceGroup().location

@description('Base URL for the reference templates and scripts')
param baseUrl string = 'https://my.base/url'

@description('Name of the Network Watcher attached to your subscription. Format: NetworkWatcher_<region_name>')
param NetworkWatcherName string = 'NetworkWatcher_${location}'

@description('Chosen name of your Flow log resource')
param FlowLogName string = 'FlowLog1'

@description('Resource ID of the target NSG')
param existingNSG string

@minValue(0)
@maxValue(365)
@metadata({
  description: 'Retention period in days. Default is zero which stands for permanent retention. Can be any Integer from 0 to 365'
  range: 'From 0 to 365.'
})
param RetentionDays int = 0

@allowed([
  '1'
  '2'
])
@description('FlowLogs Version. Correct values are 1 or 2 (default)')
param FlowLogsversion string = '2'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_ZRS'
])
@description('Storage Account type')
param storageAccountType string = 'Standard_LRS'

var foo = 'foo'
var armBaseUrl = baseUrl
var module1Url = '${armBaseUrl}/nested/module1.json'
var module2Url = '${armBaseUrl}/nested/module2.json'
var objectVar = {
  val1: 'a${location}b'
}
var arrayVar = [
  'abc'
  location
]
var storageAccountName_var = 'flowlogs${uniqueString(resourceGroup().id)}'

resource foo_bar 'Foo.Rp/bar@2019-06-01' = if (false) {
//@[17:40) [BCP081 (Warning)] Resource type "Foo.Rp/bar@2019-06-01" does not have types available. |'Foo.Rp/bar@2019-06-01'|
  name: '${foo}bar'
  location: 'westus'
  properties: {
    foo: 'bar'
  }
}

resource baz 'Foo.Rp/bar@2019-06-01' = if (something == foo) {
//@[13:36) [BCP081 (Warning)] Resource type "Foo.Rp/bar@2019-06-01" does not have types available. |'Foo.Rp/bar@2019-06-01'|
  name: 'baz'
  location: 'westus'
  dependsOn: [
    foo_bar
  ]
}

module module1Deploy 'nested/module1.bicep' = if ((1 + 2) == 3) {
  name: 'module1Deploy'
  params: {
//@[2:8) [BCP035 (Error)] The specified "object" declaration is missing the following required properties: "bar", "baz", "foo". |params|
    location: location
//@[4:12) [BCP038 (Error)] The property "location" is not allowed on objects of type "params". Permissible properties include "bar", "baz", "foo", "qux". |location|
    objectParam: objectVar
//@[4:15) [BCP038 (Error)] The property "objectParam" is not allowed on objects of type "params". Permissible properties include "bar", "baz", "foo", "qux". |objectParam|
    arrayParam: arrayVar
//@[4:14) [BCP038 (Error)] The property "arrayParam" is not allowed on objects of type "params". Permissible properties include "bar", "baz", "foo", "qux". |arrayParam|
  }
}

module module2Deploy 'nested/module2.bicep' = if ((1 + 2) == 3) {
  name: 'module2Deploy'
  params: {
//@[2:8) [BCP035 (Error)] The specified "object" declaration is missing the following required properties: "stringParam". |params|
    location: location
//@[4:12) [BCP038 (Error)] The property "location" is not allowed on objects of type "params". Permissible properties include "stringParam". |location|
    objectParam: objectVar
    arrayParam: arrayVar
  }
}

resource storageaccountname 'microsoft.storage/storageaccounts@2019-06-01' = {
  name: storageAccountName_var
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

module deployFlowLogs './nested_deployFlowLogs.bicep' = if (true) {
  name: 'deployFlowLogs'
  scope: resourceGroup('NetworkWatcherRG')
  params: {
    location: location
    NetworkWatcherName: NetworkWatcherName
    FlowLogName: FlowLogName
    existingNSG: existingNSG
    RetentionDays: RetentionDays
    FlowLogsversion: FlowLogsversion
    storageAccountResourceId: storageaccountname.id
  }
}
