import React from 'react';
import { get } from "lodash"

import { durationItems } from "./../banManagement/static.banDuration"
import { maxFailedItems } from "./../banManagement/static.maxFailedItems"

import { withSecretSeed } from "../secretSeed/Container"
import { withNetworkOptions } from "../networkOptions/Container"
import { withBanManagement } from "../banManagement/Container"
import { withAdministrativeInterface } from "../administrativeInterface/Container"
import { withAppState } from "../steps/AppState"

import ButtonReset from "../items/controls/buttonReset"

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
          const network = get(props, ["networkOptions", "stepItems", "network", "value"], []).map(item => item.value);

          let config = {
              validator: {
                  enabled: get(props, ["secretSeed", "stepItems", "isvalidator", "value"]),
              },

              dns: dns.length > 0 ? dns.map(item => item.value) : ["seed.bosagora.io"],

              banman: {
                  max_failed_requests: get(props, ["banManagement", "stepItems", "maxfailedrequests", "value"], maxFailedItems[1].value),
                  ban_duration: get(props, ["banManagement", "stepItems", "banduration", "seconds"], durationItems[0].seconds),
              },

              admin: {
                  enabled: !get(props, ["administrativeInterface", "stepItems", "enabled", "value"], false),
              },
          };

          if (network.length)
              config.network = network;

          if (config.validator.enabled)
          {
              config.validator.seed = get(props, ["secretSeed", "stepItems", "seed", "value"], null);
              // TODO: Make configurable or remove
              config.validator.registry_address = "https://registry.bosagora.io";
          }

          if (config.admin.enabled)
          {
              config.admin.address = get(props, ["administrativeInterface", "stepItems", "address", "value"], "");
              config.admin.port = get(props, ["administrativeInterface", "stepItems", "port", "value"], 1);
          }

          onRequest(config);
      }
  }

  return <ButtonReset onClick={handleValidateBanManagement.bind(this, props)}>
    {props.children}
  </ButtonReset>
}

export default withAppState(withAdministrativeInterface(withBanManagement(withSecretSeed(withNetworkOptions(ButtonRequest)))))
