import React, { Component } from 'react'
import { get } from 'lodash';
import { debounce } from 'throttle-debounce';
import Slider from '@material-ui/core/Slider';
import { withStyles } from '@material-ui/core/styles';

import { subdivideNumber } from "../../services/service.number"

import variables from './../../../values.module.scss'
import styles from "./numberSliderWrapper.module.scss"

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
        "-webkitFilter": "blur(20px)",
        filter: "blur(20px)",
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

class NumberSliderWrapper extends Component {
  constructor(props) {
    super(props);

    this.state = {
      value: 0,
    }

    this.handleChangeDebounce = debounce(300, get(this.props, "onChange", () => { }))
  }

  componentDidMount() {
    const { name, min, valueStore } = this.props
    const value = get(valueStore, [name, "value"], min)

    this.setState({ value: value })
  }

  componentDidUpdate(prevState, prevProps) {
    const { value } = this.state
    const { name, valueStore } = this.props

    if (prevState.value !== value && get(valueStore, [name, "value"]) !== value)
      this.handleChangeDebounce(name, value)
  }

  handleSliderChange(e, value) {
    const { name } = this.props

    this.setState({ value: value })
  }

  render() {
    const { min, max } = this.props
    const { value } = this.state

    return (
      <div className={styles.sliderWrapper}>
        <span className={styles.container_label}>{subdivideNumber(value)}</span>

        <CssSlider
          ThumbComponent={AirbnbThumbComponent}
          value={value}
          onChange={this.handleSliderChange.bind(this)}
          min={get(this.props, ["min"], 1)}
          max={get(this.props, ["max"], 100)}
          step={get(this.props, ["step"], 1)}
        />

        <div className={styles.sliderMarks}>
          <span className={styles.startMark}>{subdivideNumber(min)}</span>
          <span className={styles.endMark}>{subdivideNumber(max)}</span>
        </div>
      </div>
    )
  }
}

export default React.memo(NumberSliderWrapper)