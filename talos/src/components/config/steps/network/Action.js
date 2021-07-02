import { createActionTypesOf } from '../../../../utils/helpers';
import { validateDNS, validateNetwork } from '../../../../services/service.validate'

export const CHANGE_NETWORK_ITEMS = createActionTypesOf("CHANGE_NETWORK_ITEMS")

export const changeNetworkItems = (name, value, isTouched) => {
  switch (name) {
    case "network": {
      let isValid = true

      if (value.length > 0)
        value.map(item => {
          if (!validateNetwork(item.value))
            isValid = false

          return null;
        })

      const validString = !isValid
        ? 'Please enter a valid value: (userinfo@  IP address ":" port )"'
        : ""

      return {
        type: CHANGE_NETWORK_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    case "dns": {
      let isValid = true

      if (value.length > 0)
        value.map(item => {
          if (!validateDNS(item.value))
            isValid = false

          return null;
        })

      const validString = !isValid
        ? 'Invalid input value, please see the tooltip for requirements'
        : ""

      return {
        type: CHANGE_NETWORK_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
    default: {
      const isValid = true
      const validString = ""

      return {
        type: CHANGE_NETWORK_ITEMS.REQUEST,
        payload: { name, value, isTouched, isValid, validString },
      }
    }
  }
}
