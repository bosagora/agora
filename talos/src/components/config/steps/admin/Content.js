import React from 'react';
import { get } from 'lodash'

import { withAdmin } from "./Container"

import SecondTitleBold from "components/items/static/secondTitleBold"
import InputWrapperControlled from "components/items/controls/inputWrapperControlled"
import InputPopoverWrapper from "components/items/controls/inputPopoverWrapper"
import SwitcherWrapper from "components/items/controls/switcherWrapper"
import Paragraph from "components/items/static/paragraph"

import styles from "./Content.module.scss"

const DEFAULT_VALUE_ADDRESS = "127.0.0.1"
const DEFAULT_VALUE_PORT = 2827

const handleChangeInterface = (props, name, value) => {
  const { onChangeAdminItems, onSetValidAdminItem } = props

  onChangeAdminItems(name, value)

  //if choosed "interface" as true (invert value truu mean interface false)
  if (value) {
    // name, validState, value
    onSetValidAdminItem("address", true, "")
    onSetValidAdminItem("port", true, "")
  } else {
    // name, value, isTouched
    onChangeAdminItems("address", DEFAULT_VALUE_ADDRESS, true)
    onChangeAdminItems("port", DEFAULT_VALUE_PORT, true)
  }
}

const AdminContent = props => {
  const { admin, onChangeAdminItems } = props

  return (
    <div className={styles.wrapAdminItems}>

      <SecondTitleBold>Administrative Interface</SecondTitleBold>

      <div className={styles.container_interface}>
        <SwitcherWrapper
          name="enabled"
          label="Interface"
          defaultValue={!true}
          onChange={handleChangeInterface.bind(this, props)}
          valueStore={admin.stepItems}
        />
        {
          get(admin, ["stepItems", "enabled", "value"], false)
            ? <Paragraph>Note: With this disabled, you won`t be able to directly make changes to your node via the web interface. This setting (and others) will need to be changed via the configuration file.</Paragraph>
            : null
        }
      </div>

      <div className={styles.address}>
        <div className={styles.container_address}>
          <InputPopoverWrapper content={<p>The address on which your interface will be available. Make sure this is not publicly available. See our <a href="https://bosagora.io/docs/admin-interface-address" rel="noreferrer" target="_blank">documentation</a> for more details</p>}>
            <InputWrapperControlled
              name="address"
              label="Address"
              defaultValue={DEFAULT_VALUE_ADDRESS}
              disabled={get(admin, ["stepItems", "enabled", "value"], false)}
              onChange={onChangeAdminItems}
              valueStore={admin.stepItems}
            />
          </InputPopoverWrapper>
        </div>

        <div className={styles.container_port}>
          <InputPopoverWrapper content={<p>The range will be 1-65535</p>}>
            <InputWrapperControlled
              name="port"
              label="Port"
              defaultValue={DEFAULT_VALUE_PORT}
              disabled={get(admin, ["stepItems", "enabled", "value"], false)}
              onChange={onChangeAdminItems}
              valueStore={admin.stepItems}
            />
          </InputPopoverWrapper>
        </div>
      </div>

    </div>
  )
}

export default withAdmin(AdminContent)
