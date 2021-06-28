import React from 'react';
import { validateDNS, validateNetwork } from "../../services/service.validate"

import { withNetworkOptions } from "../../containers/NetworkOptions"

import SecondTitleBold from "../items/static/secondTitleBold"
import InputPopoverWrapper from "../items/controls/inputPopoverWrapper"
import TokenInputWrapper from "../items/controls/tokenInputWrapper"

import styles from "./networkOptionsContent.module.scss"

const NetworkOptionsContent = props => {
  const { networkOptions, onChangeNetworkOptionsItems } = props

  return (
    <div className={styles.wrappNetworkOptionsContent}>

      <SecondTitleBold>Network Options</SecondTitleBold>

      <div className={styles.container_network}>
        <InputPopoverWrapper content={<p>This is a list of nodes you want to initially connect to. This field is only required if you haven't provided any DNS seed nodes.</p>}>
          <TokenInputWrapper
            name="network"
            label="Network"
            defaultValue={[]}
            onChange={onChangeNetworkOptionsItems}
            valueStore={networkOptions.stepItems}
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
            onChange={onChangeNetworkOptionsItems}
            valueStore={networkOptions.stepItems}
            validateAction={validateDNS}
          />
        </InputPopoverWrapper>
      </div>

    </div>
  )
}

export default withNetworkOptions(NetworkOptionsContent)
