import React from 'react';
import { get } from "lodash"

import { withValidator } from "./Container"

import SecondTitleBold from "components/items/static/secondTitleBold"
import Icon from "components/items/static/icon"
import Bold from "components/items/static/bold"
import InputWrapperControlled from "components/items/controls/inputWrapperControlled"
import InputPopoverWrapper from "components/items/controls/inputPopoverWrapper"
import TypeSecretSeedItem from "components/items/controls/typeSecretSeedItem"

import styles from "./Content.module.scss"

const DEFAULT_VALUE_SECRETSEED = ""

const handleChangeValidator = (props, name, value) => {
  const { onChangeValidatorItems, onSetValidStateValidatorItem } = props

  onChangeValidatorItems(name, value)

  //if choosed "isvalidator" as false
  if (!value)
    // name, validState, value
    onSetValidStateValidatorItem("seed", true, "")
  else
    // name, value, isTouched
    onChangeValidatorItems("seed", DEFAULT_VALUE_SECRETSEED, true)
}

const ValidatorContent = props => {
  const { validator, onChangeValidatorItems } = props

  return <div className={styles.wrapValidatorContent}>

    <SecondTitleBold>Secret Seed</SecondTitleBold>

    <div className={styles.container_typeValidator}>
      <div className={styles.chooseTypeValidator}>
        <div className={styles.chooseTypeItemWrapper}>
          <TypeSecretSeedItem
            name="isvalidator"
            value={true}
            checked
            valueStore={validator.stepItems}
            icon={<Icon name="validator" />}
            title={<Bold>Validator</Bold>}
            onClick={handleChangeValidator.bind(this, props)}
          />
        </div>

        <div className={styles.chooseTypeItemWrapper}>
          <TypeSecretSeedItem
            name="isvalidator"
            value={false}
            valueStore={validator.stepItems}
            icon={<Icon name="full-node" />}
            title={<Bold>Full Node</Bold>}
            onClick={handleChangeValidator.bind(this, props)}
          />
        </div>
      </div>
    </div>

    <div className={styles.container_validatorInput}>
      <InputPopoverWrapper content={<p>This is a 56 character string starting with 'S'. See our <a href="https://bosagora.io/" target="_black">documentation</a> for more details.</p>}>
        <InputWrapperControlled
          name="seed"
          label="Enter Secret Seed here"
          disabled={!get(validator, ["stepItems", "isvalidator", "value"], true)}
          onChange={onChangeValidatorItems}
          valueStore={validator.stepItems}
        />
      </InputPopoverWrapper>
    </div>

  </div>
}

export default withValidator(ValidatorContent)
