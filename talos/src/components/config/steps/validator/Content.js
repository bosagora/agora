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
import { Component } from 'react';

const DEFAULT_VALUE_SECRETSEED = ""

const ValidatorContent = props => {
  const { validator, onChangeValidatorItems, onSetValidStateValidatorItem } = props

  return <div className={styles.wrapValidatorContent}>

    <SecondTitleBold>Secret Seed</SecondTitleBold>
    <CardSelector
      defaultIndex={get(validator, ["stepItems", "isvalidator", "value"], true) ? 0 : 1}
      onChange={(index) => {
        onChangeValidatorItems("isvalidator", index === 0);
        if (index === 1)
          // name, validState, value
          onSetValidStateValidatorItem("seed", true, "")
        else
          // name, value, isTouched
          onChangeValidatorItems("seed", DEFAULT_VALUE_SECRETSEED, true)
        }}
    />
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

class CardSelector extends Component
{
  constructor(props) {
    super(props);
    this.state = {
      currentIndex: props.defaultIndex,
      // This stays constant through the object's lifetime
      onChange: props.onChange,
    };
  }

  onCardClick(index) {
    // Ignore clicks on the same index
    if (index === this.state.currentIndex)
      return;

    this.setState({ currentIndex: index});
    this.state.onChange(index);
  }

  render() {
    return (
    <div className={styles.container_typeValidator}>
      <div className={styles.chooseTypeValidator}>
        <TypeSecretSeedItem
          index={0}
          currentIndex={this.state.currentIndex}
          icon={<Icon name="validator" />}
          title={<Bold>Validator</Bold>}
          onClick={this.onCardClick.bind(this)}
        />

        <TypeSecretSeedItem
          index={1}
          currentIndex={this.state.currentIndex}
          icon={<Icon name="full-node" />}
          title={<Bold>Full Node</Bold>}
          onClick={this.onCardClick.bind(this)}
        />
      </div>
    </div>
    );
  }
}

export default withValidator(ValidatorContent)
