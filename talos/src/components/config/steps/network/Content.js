import React from 'react';
import { validateDNS, validateNetwork } from "../../../../services/service.validate"

import { withNetwork } from "./Container"

import SecondTitleBold from "../../../items/static/secondTitleBold"
import InputPopoverWrapper from "../../../items/controls/inputPopoverWrapper"
import TokenInputWrapper from "../../../items/controls/tokenInputWrapper"

import styles from "./Content.module.scss"

const NetworkContent = props => {
  const { network, isValidator, onChangeNetworkItems } = props

  return (
    <div className={styles.wrapNetworkContent}>

      <SecondTitleBold>Listening interface</SecondTitleBold>
      <br/>

      { isValidator && <p>Configue the listening interface your validator will be using.
        A Validator requires at least one listening interface on which it is reachable by other validators.</p> }

      { !isValidator && <p>Configure the listening interface your full node will be reachable at.
        The listening interface is optional for full nodes, however disabling it may have unintended consequences,
        such as delay in blockchain data. </p> }

      <br/>
      <p>By default, Agora nodes use the port 2826. Make sure that your network allows connections on that port.</p>

      <div className={styles.container_network}>
        <InputPopoverWrapper content={<p>This is a list of interfaces your node will be listening to. The default listens publicly on port 2826.
          You might want to listen privately to a specific IP (e.g. if you're using a tunnel or Tor), or listen to more than one interface.</p>}>
          <TokenInputWrapper
            name="network"
            label="Listening interfaces"
            defaultValue={[{ value: "https://0.0.0.0:2826" }]}
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
