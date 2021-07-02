import React from 'react';
import { get } from "lodash"

import { durationItems, maxFailedItems } from "components/config/steps/banman/static"

import { withValidator } from "components/config/steps/validator/Container"
import { withNetwork } from "components/config/steps/network/Container"
import { withBanman } from "components/config/steps/banman/Container"
import { withAdmin } from "components/config/steps/admin/Container"
import { withAppState } from "components/app/State"

import ButtonReset from "components/items/controls/buttonReset"

const ButtonRequest = props => {

  const handleValidateBanman = props => {
    const {
      admin,
      onRequest,
      onChangeAdminItems
    } = props
    var isValidStep = true

    Object.keys(admin.stepItems).map(key => {

      const item = admin.stepItems[key]
      if (!!item.isValid) {
        if (!item.isValid)
          isValidStep = false
      }
      else {
        isValidStep = false

        if (typeof item.isValid === "undefined")
          onChangeAdminItems(key, !!item.value ? item.value : "")
      }

      return null
    })

    const dns = get(props, ["network", "stepItems", "dns", "value"], [])

      if (isValidStep) {
          const network = get(props, ["network", "stepItems", "network", "value"], []).map(item => item.value);

          let config = {
              validator: {
                  enabled: get(props, ["validator", "stepItems", "isvalidator", "value"]),
              },

              dns: dns.length > 0 ? dns.map(item => item.value) : ["seed.bosagora.io"],

              banman: {
                  max_failed_requests: get(props, ["banman", "stepItems", "maxfailedrequests", "value"], maxFailedItems[1].value),
                  ban_duration: get(props, ["banman", "stepItems", "banduration", "seconds"], durationItems[0].seconds),
              },

              admin: {
                  enabled: !get(props, ["admin", "stepItems", "enabled", "value"], false),
              },
          };

          if (network.length)
              config.network = network;

          if (config.validator.enabled)
          {
              config.validator.seed = get(props, ["validator", "stepItems", "seed", "value"], null);
              // TODO: Make configurable or remove
              config.validator.registry_address = "https://registry.bosagora.io";
          }

          if (config.admin.enabled)
          {
              config.admin.address = get(props, ["admin", "stepItems", "address", "value"], "");
              config.admin.port = get(props, ["admin", "stepItems", "port", "value"], 1);
          }

          onRequest(config);
      }
  }

  return <ButtonReset onClick={handleValidateBanman.bind(this, props)}>
    {props.children}
  </ButtonReset>
}

export default withAppState(withAdmin(withBanman(withValidator(withNetwork(ButtonRequest)))))
