import React, { Component } from 'react'
import { get, has } from 'lodash';
import Slider from '@material-ui/core/Slider';
import { withStyles } from '@material-ui/core/styles';

import { isDesktop } from "../../../services/responsive.service"

import variables from './../../../values.module.scss'
import styles from "./itemsSliderWrapper.module.scss"

const AirbnbThumbComponent = props => {
  return (
    <span {...props}>
      <span className="backRound">
        <span className="dotRound" />
      </span>
      <span className="shadow" />
    </span>
  );
}

const CssSlider = withStyles({
  root: {
    color: variables.color_primary,
    height: 5,
    "& .MuiSlider-rail": {
      height: 5,
      borderRadius: 2.5,
    },
    "& .MuiSlider-track": {
      height: 5,
      borderRadius: 2.5,
    },
    "& .MuiSlider-thumb": {
      height: 37,
      width: 37,
      marginTop: -18.5,
      marginLeft: -18.5,
      zIndex: 1,
      opacity: 1,
      background: "none",
      display: "flex",
      justifyContent: "center",
      alignItems: "center",
      '& .backRound': {
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        width: 33,
        height: 33,
        backgroundColor: variables.color_white,
        borderRadius: "50%",
        zIndex: 2,
        transition: "width 0.1s, height 0.1s",
        '& .dotRound': {
          width: 7,
          height: 7,
          backgroundColor: variables.color_primary,
          borderRadius: "50%",
          zIndex: 3,
          transition: "width 0.1s, height 0.1s",
        },
      },
      '& .shadow': {
        display: "block",
        position: "absolute",
        width: 25,
        height: 25,
        top: 11,
        left: 4,
        backgroundColor: variables.color3,
        opacity: 0.5,
        borderRadius: 0,
        "-webkitFilter": isDesktop() ? "blur(20px)" : "blur(10px)",
        filter: isDesktop() ? "blur(20px)" : "blur(10px)",
        zIndex: 1,
      },
      '&:hover,&.MuiSlider-active': {
        boxShadow: "none",
        '& .backRound': {
          width: 37,
          height: 37,
          '& .dotRound': {
            width: 5,
            height: 5,
          },
        },
        '& .shadow': {
        },
      },
    },
  },
})(Slider);

class ItemsSliderWrapper extends Component {
  constructor(props) {
    super(props);

    this.getIndexItemsByValue = this.getIndexItemsByValue.bind(this)
  }

  getIndexItemsByValue(value) {
    const { items } = this.props
    var nextIndex = 0

    items.map((item, index) => {
      if (item.value === value)
        nextIndex = index
    })

    return nextIndex
  }

  componentDidMount() {
    const { name, valueStore, onChange, items } = this.props

    if (!has(valueStore, [name, "value"]))
      onChange(name, get(items, [get(this.props, ["defaultValue"], 0), "value"]), true)
  }

  handleSliderChange(e, value) {
    const { name, items, onChange, valueStore } = this.props

    if (this.getIndexItemsByValue(get(valueStore, [name, "value"])) !== value)
      onChange(name, get(items, [value, "value"]), true)
  }

  render() {
    const { items, name, valueStore } = this.props
    const min = 0
    const max = items.length - 1
    const defaultIndex = has(valueStore, [name, "value"])
      ? this.getIndexItemsByValue(get(valueStore, [name, "value"]))
      : get(this.props, ["defaultValue"], 0)

    return (
      <div className={styles.sliderWrapper}>
        <span className={styles.container_label}>{items[defaultIndex].title}</span>

        <CssSlider
          ThumbComponent={AirbnbThumbComponent}
          value={defaultIndex}
          onChange={this.handleSliderChange.bind(this)}
          min={min}
          max={max}
          step={1}
        />

        <div className={styles.sliderMarks}>
          <span className={styles.startMark}>{items[min].title}</span>
          <span className={styles.endMark}>{items[max].title}</span>
        </div>
      </div>
    )
  }
}

export default React.memo(ItemsSliderWrapper)
