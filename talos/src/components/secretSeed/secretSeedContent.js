import React from 'react';
import { get } from "lodash"

import { withSecretSeed } from "../../shared/containers/containerSecretSeed"

import SecondTitleBold from "../../shared/items/static/secondTitleBold"
import Icon from "../../shared/items/static/icon"
import Bold from "../../shared/items/static/bold"
// import InputWrapper from "../../shared/items/controls/inputWrapper"
import InputWrapperControlled from "../../shared/items/controls/inputWrapperControlled"
import InputPopoverWrapper from "../../shared/items/controls/inputPopoverWrapper"
import TypeSecrerSeedItem from "../../shared/items/controls/typeSecrerSeedItem"

import styles from "./secretSeedContent.module.scss"

const DEFAULT_VALUE_SECRETSEED = ""

const handleChangeValidator = (props, name, value) => {
  const { onChangeSecretSeedItems, onSetValidStateSecretSeedItem } = props

  onChangeSecretSeedItems(name, value)

  //if choosed "isvalidator" as false
  if (!value)
    // name, validState, value
    onSetValidStateSecretSeedItem("seed", true, "")
  else
    // name, value, isTouched
    onChangeSecretSeedItems("seed", DEFAULT_VALUE_SECRETSEED, true)
}

const SecretSeedContent = props => {
  const { secretSeed, onChangeSecretSeedItems } = props

  return <div className={styles.wrappSecretSeedContent}>

    <SecondTitleBold>Secret Seed</SecondTitleBold>

    <div className={styles.container_typeSecretSeed}>
      <div className={styles.chooseTypeSecretSeed}>
        <div className={styles.chooseTypeItemWrapper}>
          <TypeSecrerSeedItem
            name="isvalidator"
            value={true}
            checked
            valueStore={secretSeed.stepItems}
            icon={<Icon name="validator" />}
            title={<Bold>Validator</Bold>}
            onClick={handleChangeValidator.bind(this, props)}
          />
        </div>

        <div className={styles.chooseTypeItemWrapper}>
          <TypeSecrerSeedItem
            name="isvalidator"
            value={false}
            valueStore={secretSeed.stepItems}
            icon={<Icon name="full-node" />}
            title={<Bold>Full Node</Bold>}
            onClick={handleChangeValidator.bind(this, props)}
          />
        </div>
      </div>
    </div>

    <div className={styles.container_secrerSeedInput}>
      <InputPopoverWrapper content={<p>This is a 56 character string starting with 'S'. See our <a href="https://bosagora.io/" target="_black">documentation</a> for more details.</p>}>
        <InputWrapperControlled
          name="seed"
          label="Enter Secret Seed here"
          disabled={!get(secretSeed, ["stepItems", "isvalidator", "value"], true)}
          onChange={onChangeSecretSeedItems}
          valueStore={secretSeed.stepItems}
        />
      </InputPopoverWrapper>
    </div>

  </div>
}

export default withSecretSeed(SecretSeedContent)
