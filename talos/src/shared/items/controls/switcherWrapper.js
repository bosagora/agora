import React, { Component } from 'react'
import { get, has } from "lodash"
import Switch from '@material-ui/core/Switch';
import { withStyles } from '@material-ui/core/styles';

import variables from './../../../values.scss'
import styles from './switcherWrapper.module.scss'

const AntSwitch = withStyles(theme => ({
  root: {
    width: 46,
    height: 22,
    padding: 0,
    display: 'flex',
  },
  switchBase: {
    padding: 2,
    color: variables.color_white,
    '&$checked': {
      transform: 'translateX(24px)',
      color: variables.color_white,
      '& + $track': {
        opacity: 1,
        backgroundColor: variables.color_negative,
        border: 0,
      },
    },
  },
  thumb: {
    width: 18,
    height: 18,
    boxShadow: 'none',
  },
  track: {
    border: 0,
    borderRadius: 22 / 2,
    opacity: 1,
    backgroundColor: variables.color_primary,
  },
  checked: {},
}))(Switch);

class SwitcherWrapper extends Component {
  componentDidMount() {
    const { name, valueStore, onChange } = this.props

    if (!has(valueStore, [name]))
      onChange(name, get(this.props, ["defaultValue"], ""))
  }

  handleChange(e) {
    const { name, onChange } = this.props

    onChange(name, e.target.checked)
  }

  render() {
    const { label, name, valueStore } = this.props

    return (
      <div className={styles.switcher}>
        <div className={styles.container_switcher}>
          <AntSwitch
            id={name}
            checked={get(valueStore, [name, "value"], get(this.props, ["defaultValue"], false))}
            onChange={this.handleChange.bind(this)}
          />
        </div>
        {
          has(this.props, ["label"])
            ? <div className={styles.container_label}>
              {label}
            </div>
            : null
        }
      </div>
    )
  }
}

export default React.memo(SwitcherWrapper)