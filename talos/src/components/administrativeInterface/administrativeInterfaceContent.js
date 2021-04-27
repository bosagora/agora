import React from 'react';
import { get } from 'lodash'

import { withAdministrativeInterface } from "../../shared/containers/containerAdministrativeInterface"

import SecondTitleBold from "../../shared/items/static/secondTitleBold"
// import InputWrapper from "../../shared/items/controls/inputWrapper"
import InputWrapperControlled from "../../shared/items/controls/inputWrapperControlled"
import InputPopoverWrapper from "../../shared/items/controls/inputPopoverWrapper"
import SwitcherWrapper from "../../shared/items/controls/switcherWrapper"
import Paragraph from "../../shared/items/static/paragraph"

import styles from "./administrativeInterfaceContent.module.scss"

const DEFAULT_VALUE_ADDRESS = "127.0.0.1"
const DEFAULT_VALUE_PORT = 2827

const handleChangeInterface = (props, name, value) => {
  const { onChangeAdministrativeInterfaceItems, onSetValidAdministrativeInterfaceItem } = props

  onChangeAdministrativeInterfaceItems(name, value)

  //if choosed "interface" as true (invert value truu mean interface false)
  if (value) {
    // name, validState, value
    onSetValidAdministrativeInterfaceItem("address", true, "")
    onSetValidAdministrativeInterfaceItem("port", true, "")
  } else {
    // name, value, isTouched
    onChangeAdministrativeInterfaceItems("address", DEFAULT_VALUE_ADDRESS, true)
    onChangeAdministrativeInterfaceItems("port", DEFAULT_VALUE_PORT, true)
  }
}

const AdministrativeInterfaceContent = props => {
  const { administrativeInterface, onChangeAdministrativeInterfaceItems } = props

  return (
    <div className={styles.wrappAdministrativeInterfaceItems}>

      <SecondTitleBold>Administrative Interface</SecondTitleBold>

      <div className={styles.container_interface}>
        <SwitcherWrapper
          name="enabled"
          label="Interface"
          defaultValue={!true}
          onChange={handleChangeInterface.bind(this, props)}
          valueStore={administrativeInterface.stepItems}
        />
        {
          get(administrativeInterface, ["stepItems", "enabled", "value"], false)
            ? <Paragraph>Note: With this disabled, you won`t be able to directly make changes to your node via the web interface. This setting (and others) will need to be changed via the configuration file.</Paragraph>
            : null
        }
      </div>

      <div className={styles.address}>
        <div className={styles.container_address}>
          <InputPopoverWrapper content={<p>The address on which your interface will be available. Make sure this is not publicly available. See our <a href="https://bosagora.io/docs/admin-interface-address" target="_blank">documentation</a> for more details</p>}>
            <InputWrapperControlled
              name="address"
              label="Address"
              defaultValue={DEFAULT_VALUE_ADDRESS}
              disabled={get(administrativeInterface, ["stepItems", "enabled", "value"], false)}
              onChange={onChangeAdministrativeInterfaceItems}
              valueStore={administrativeInterface.stepItems}
            />
          </InputPopoverWrapper>
        </div>

        <div className={styles.container_port}>
          <InputPopoverWrapper content={<p>The range will be 1-65535</p>}>
            <InputWrapperControlled
              name="port"
              label="Port"
              defaultValue={DEFAULT_VALUE_PORT}
              disabled={get(administrativeInterface, ["stepItems", "enabled", "value"], false)}
              onChange={onChangeAdministrativeInterfaceItems}
              valueStore={administrativeInterface.stepItems}
            />
          </InputPopoverWrapper>
        </div>
      </div>

    </div>
  )
}

export default withAdministrativeInterface(AdministrativeInterfaceContent)
