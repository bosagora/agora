import React from 'react';
import { validateDNS, validateNetwork } from "../../../../services/service.validate"

import { withNetwork } from "./Container"

import SecondTitleBold from "../../../items/static/secondTitleBold"
import InputPopoverWrapper from "../../../items/controls/inputPopoverWrapper"
import TokenInputWrapper from "../../../items/controls/tokenInputWrapper"

import styles from "./Content.module.scss"

const NetworkContent = props => {
  const { network, onChangeNetworkItems } = props

  return (
    <div className={styles.wrapNetworkContent}>

      <SecondTitleBold>Network Options</SecondTitleBold>

      <div className={styles.container_network}>
        <InputPopoverWrapper content={<p>This is a list of nodes you want to initially connect to. This field is only required if you haven't provided any DNS seed nodes.</p>}>
          <TokenInputWrapper
            name="network"
            label="Network"
            defaultValue={[]}
            onChange={onChangeNetworkItems}
            valueStore={network.stepItems}
            validateAction={validateNetwork}
          />
        </InputPopoverWrapper>
      </div>
      <div className={styles.container_dns}>
        <InputPopoverWrapper content={<p>Enter IP addresses or domain names for DNS seeds. See our <a href="https://bosagora.io/docs/dns-seed" target="_black">documentation</a> for more details."</p>}>
          <TokenInputWrapper
            name="dns"
            label="DNS"
            defaultValue={[
              {
                value: "seed.bosagora.io"
              }
            ]}
            onChange={onChangeNetworkItems}
            valueStore={network.stepItems}
            validateAction={validateDNS}
          />
        </InputPopoverWrapper>
      </div>

    </div>
  )
}

export default withNetwork(NetworkContent)
