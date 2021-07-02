import React from 'react';

import { durationItems, maxFailedItems } from "./static"
import { withBanman } from "./Container"

import SecondTitleBold from "components/items/static/secondTitleBold"
import CounterWrapper from "./counterWrapper"
import InputLabel from "components/items/static/inputLabel"
import ItemsSliderWrapper from "components/items/controls/itemsSliderWrapper"
import SliderPopoverWrapper from "components/items/controls/sliderPopoverWrapper"

import styles from "./Content.module.scss"

const BanmanContent = props => {
  const { banman, onChangeBanmanItems } = props

  return (
    <div className={styles.wrapBanmanContent}>

      <SecondTitleBold>Ban Management</SecondTitleBold>

      <div className={styles.container_counter}>
        <InputLabel>Max failed requests until an address is banned</InputLabel>
        <CounterWrapper
          items={maxFailedItems}
          name="maxfailedrequests"
          defaultValue={maxFailedItems[1]}
          valueStore={banman.stepItems}
          onChange={onChangeBanmanItems}
        />
      </div>
      <div className={styles.container_banDuration}>
        <InputLabel>Ban Duration</InputLabel>
        <SliderPopoverWrapper content={<p>When your node is banned or rejects data after a few attempts the cause is likely connectivity or latency issues. Please try the safe default values of: "Max Failed Requests": 10 and "Ban Duration": 1 Day."</p>}>
          <ItemsSliderWrapper
            items={durationItems}
            name="banduration"
            defaultValue={1}
            valueStore={banman.stepItems}
            onChange={onChangeBanmanItems}
          />
        </SliderPopoverWrapper>
      </div>
    </div>
  )
}

export default withBanman(BanmanContent)
