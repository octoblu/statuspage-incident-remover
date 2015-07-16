StatusPageAPI = require 'statuspage-api'
request       = require 'request'
_             = require 'lodash'

PAGE_ID = process.env.STATUSPAGE_PAGE_ID
API_KEY = process.env.STATUSPAGE_API_KEY

class StatusRemover
  constructor: ->
    @statuspage = new StatusPageAPI
      pageid: PAGE_ID
      apikey: API_KEY

  remove: (name) =>
    @getByName name, (incidents) =>
      console.log 'incidents', _.uniq _.pluck(incidents, 'name')
      console.log 'incidents count: ', _.size(incidents)
      last = 0
      _.each incidents, (incident) =>
        last += 1000
        _.delay @deleteById, last, incident.id

  deleteById: (id) =>
    console.log 'deleting ', id
    requestData =
      headers:
        'Authorization': API_KEY
      form: true
      url: "https://api.statuspage.io/v1/pages/#{PAGE_ID}/incidents/#{id}"
      method: 'DELETE'

    request requestData, (error, result, body) =>
      return console.error 'error deleting', error if error?
      console.log 'status result after delete', result.statusCode

  getByName: (name, callback=->) =>
    console.log 'getting incidents', name
    @statuspage.get 'incidents', (result) =>
      console.log 'get incidents status', result.status
      return console.error 'get incidents error', result.error if result.error?
      callback _.filter result.data, name: name

module.exports = StatusRemover
