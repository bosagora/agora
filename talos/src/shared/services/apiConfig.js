import configuration from './../../config.json'

var config = {
    get: function (param) {
        if (param === undefined) {
            return configuration
        } else {
            for (var key in configuration) {
                if (key === param) {
                    return configuration[param]
                } else {
                    return null
                }
            }
        }
    }
}

export default config