import React, { Component } from 'react'
import { get, has } from "lodash"
import TextField from '@material-ui/core/TextField';
import { withStyles } from '@material-ui/core/styles';

import { isDesktop } from "../../services/responsive.service"

import variables from './../../../values.scss'
import styles from "./inputWrapperControlled.module.scss"

const CssTextField = withStyles({
  root: {
    '& .MuiFormLabel-root': {
      fontFamily: variables.font1,
      fontSize: isDesktop() ? '1.4rem' : '1rem',
      lineHeight: isDesktop() ? 1.14 : 1.5,
      opacity: 0.4,
      color: variables.color_black,
      fontWeight: 'normal',
      '&.Mui-focused': {
        color: variables.color_black,
        fontSize: '1rem',
        lineHeight: 1.14,
        opacity: 0.66,
      },
      '&.MuiInputLabel-shrink': {
        color: variables.color_black,
        fontSize: '1rem',
        lineHeight: isDesktop() ? 1.14 : 1.5,
        opacity: 0.66,
      }
    },
    '& .MuiInputBase-root': {
      fontSize: isDesktop() ? '1.4rem' : '1rem',
      lineHeight: 1.14,
      letterSpacing: 'inherit',
    },
    '& .MuiInput-underline:before': {
      bottom: '-1px',
    },
    '& .MuiInput-underline:after': {
      bottom: '-1px',
      borderBottomWidth: "1px",
      borderBottomColor: variables.color_black,
    },
    '&:hover .MuiInput-underline:before': {
      borderBottomWidth: "1px",
    },
    '& label.Mui-disabled': {
      color: variables.color_black,
      opacity: 0.4
    },
    '& .MuiInputBase-input': {
      height: isDesktop() ? '50px' : '40px',
      paddingRight: '55px',
      fontFamily: variables.font1,
    },
    '& .MuiInput-underline.Mui-disabled': {
      '&:before': {
        borderBottomStyle: "solid",
        borderBottomColor: variables.color_black,
        opacity: 0.1,
      },
    },
    '& label.Mui-error': {
      color: variables.color_black,
      opacity: 0.4
    },
    '& .MuiInput-underline[class*="Mui-error"]': {
      '&:before': {
        borderBottom: isDesktop() ? 'solid 1px ' + variables.color_negative : '0px',
        opacity: 1,
      },
      '&:after': {
        borderBottom: isDesktop() ? 'solid 1px ' + variables.color_negative : '0px',
        opacity: 1,
      },
    },
    '& .MuiFormHelperText-root': {
      fontFamily: variables.font1,
      fontSize: isDesktop() ? '1rem' : '0.8rem',
      lineHeight: 1.5,
      fontWeight: 'normal',
      marginTop: isDesktop() ? '9px' : '0px',
      paddingTop: isDesktop() ? '0px' : '9px',
      position: isDesktop() ? 'absolute' : 'static',
      borderTop: isDesktop() ? '0px' : 'solid 1px ' + variables.color_negative,
      left: 0,
      top: '100%',
      letterSpacing: 'inherit',
      '&.Mui-error': {
        color: variables.color_negative,
      }
    }
  },
})(TextField)

class InputWrapperControlled extends Component {
  componentDidMount() {
    const { name, onChange, valueStore } = this.props

    if (!has(valueStore, [name]) && !get(this.props, ["disabled"], false)) {

      onChange(name, get(this.props, ["defaultValue"], ""), false)
    }
  }

  handleChange(e) {
    const { name, onChange } = this.props

    onChange(name, e.target.value, true)
  }

  handleBlur(e) {
    const { name, onChange, valueStore } = this.props

    if (e.target.value.length === 0 && !get(valueStore, [name, "isTouched"], false))
      onChange(name, "", true)
  }

  render() {
    const { name, label, valueStore } = this.props
    const isError = get(valueStore, [name, "isTouched"], false) && !get(valueStore, [name, "isValid"], true)
    const validString = get(valueStore, [name, "isTouched"], false) ? get(valueStore, [name, "validString"], "") : ""

    return (
      <div className={styles.inputWrapper}>
        <CssTextField
          id={name}
          label={label}
          onChange={this.handleChange.bind(this)}
          onBlur={this.handleBlur.bind(this)}
          fullWidth
          value={get(valueStore, [name, "value"], get(this.props, ["defaultValue"], ""))}
          disabled={get(this.props, ["disabled"], false)}
          error={isError}
          helperText={validString}
        />
      </div>
    )
  }
}

export default React.memo(InputWrapperControlled)