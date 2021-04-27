"use stric"

import api from './apiService.js'

export const RequestService = {
  request: function (options) {
    return api.post('/writeConfig', options)
  },
}
