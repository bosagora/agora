import React from 'react';

import { durationItems } from "./static.banDuration"
import { maxFailedItems } from "./static.maxFailedItems"
import { withBanManagement } from "../../shared/containers/containerBanManagement"

import SecondTitleBold from "../../shared/items/static/secondTitleBold"
import CounterWrapper from "./counterWrapper"
import InputLabel from "../../shared/items/static/inputLabel"
import ItemsSliderWrapper from "../../shared/items/controls/itemsSliderWrapper"
import SliderPopoverWrapper from "../../shared/items/controls/sliderPopoverWrapper"

import styles from "./banManagementContent.module.scss"

const BanManagementContent = props => {
  const { banManagement, onChangeBanManagementItems } = props

  return (
    <div className={styles.wrappBanManagementContent}>

      <SecondTitleBold>Ban Management</SecondTitleBold>

      <div className={styles.container_counter}>
        <InputLabel>Max failed requests until an address is banned</InputLabel>
        <CounterWrapper
          items={maxFailedItems}
          name="maxfailedrequests"
          defaultValue={maxFailedItems[1]}
          valueStore={banManagement.stepItems}
          onChange={onChangeBanManagementItems}
        />
      </div>
      <div className={styles.container_banDuration}>
        <InputLabel>Ban Duration</InputLabel>
        <SliderPopoverWrapper content={<p>When your node is banned or rejects data after a few attempts the cause is likely connectivity or latency issues. Please try the safe default values of: "Max Failed Requests": 10 and "Ban Duration": 1 Day."</p>}>
          <ItemsSliderWrapper
            items={durationItems}
            name="banduration"
            defaultValue={1}
            valueStore={banManagement.stepItems}
            onChange={onChangeBanManagementItems}
          />
        </SliderPopoverWrapper>
      </div>
    </div>
  )
}

export default withBanManagement(BanManagementContent)
