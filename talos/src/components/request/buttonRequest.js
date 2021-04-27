import React from 'react';
import { get } from "lodash"

import { durationItems } from "./../banManagement/static.banDuration"
import { maxFailedItems } from "./../banManagement/static.maxFailedItems"

import { withSecretSeed } from "../../shared/containers/containerSecretSeed"
import { withNetworkOptions } from "../../shared/containers/containerNetworkOptions"
import { withBanManagement } from "../../shared/containers/containerBanManagement"
import { withAdministrativeInterface } from "../../shared/containers/containerAdministrativeInterface"
import { withAppState } from "../../shared/containers/containerAppState"

import ButtonReset from "../../shared/items/controls/buttonReset"

const ButtonRequest = props => {

  const handleValidateBanManagement = props => {
    const {
      administrativeInterface,
      onRequest,
      onChangeAdministrativeInterfaceItems
    } = props
    var isValidStep = true

    Object.keys(administrativeInterface.stepItems).map(key => {

      const item = administrativeInterface.stepItems[key]
      if (!!item.isValid) {
        if (!item.isValid)
          isValidStep = false
      }
      else {
        isValidStep = false

        if (typeof item.isValid === "undefined")
          onChangeAdministrativeInterfaceItems(key, !!item.value ? item.value : "")
      }

      return null
    })

    const dns = get(props, ["networkOptions", "stepItems", "dns", "value"], [])

    if (isValidStep) {
      onRequest({
        isvalidator: get(props, ["secretSeed", "stepItems", "isvalidator", "value"]),
        seed: get(props, ["secretSeed", "stepItems", "seed", "value"], ""),

        network: get(props, ["networkOptions", "stepItems", "network", "value"], []).map(item => item.value),
        dns: dns.length > 0 ? dns.map(item => item.value) : ["seed.bosagora.io"],

        maxfailedrequests: get(props, ["banManagement", "stepItems", "maxfailedrequests", "value"], maxFailedItems[1].value),
        banduration: get(props, ["banManagement", "stepItems", "banduration", "value"], durationItems[0].value),

        enabled: !get(props, ["administrativeInterface", "stepItems", "enabled", "value"], false),
        address: get(props, ["administrativeInterface", "stepItems", "address", "value"], ""),
        port: get(props, ["administrativeInterface", "stepItems", "port", "value"], 1),
      })
    }
  }

  return <ButtonReset onClick={handleValidateBanManagement.bind(this, props)}>
    {props.children}
  </ButtonReset>
}

export default withAppState(withAdministrativeInterface(withBanManagement(withSecretSeed(withNetworkOptions(ButtonRequest)))))
