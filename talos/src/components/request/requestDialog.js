import React from 'react';
import Dialog from '@material-ui/core/Dialog';
import DialogActions from '@material-ui/core/DialogActions';
import DialogContent from '@material-ui/core/DialogContent';
import DialogTitle from '@material-ui/core/DialogTitle';
import { withStyles } from '@material-ui/core/styles';

import { REQUEST } from "components/app/Action"
import { withAppState } from "components/app/State"

import Loader from "components/items/static/loader"
import PrevButton from "components/items/static/prevButton"
import NextButton from "components/items/static/nextButton"
import ButtonRequest from "./buttonRequest"
import ButtonReset from "components/items/controls/buttonReset"
import { isDesktop } from "services/responsive.service"

import variables from 'values.module.scss'
import styles from "./requestDialog.module.scss"

const CssDialog = withStyles({
  root: {
    "& .MuiPaper-root": {
      borderRadius: "0px",
      boxShadow: "none",
      background: "none",
      margin: "0px",
      width: "100%",
      "& .MuiDialogContent-root": {
        padding: isDesktop() ? "30px 40px" : "0px",
        width: isDesktop() ? "600px" : "100%",
        maxWidth: isDesktop() ? "100%" : "600px",
        backgroundColor: variables.color_white,
        "& .MuiDialogTitle-root": {
          padding: isDesktop() ? "0px" : "16px 24px",
          "& .MuiTypography-root": {
            fontSize: "1rem",
          }
        },
        "& .MuiDialogActions-root": {
          marginTop: isDesktop() ? "60px" : "40px",
          padding: "0px",
          dispaly: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          "&.errorActions": {
            justifyContent: "space-between",
          },
          "&.successActions": {
            justifyContent: "flex-end",
          },
        }
      }
    },
  },
})(Dialog);

const isOpenDialog = (requestState) => {
  switch (requestState) {
    case (REQUEST.BEGIN):
      return false;

    case (REQUEST.END):
      return false;

    case (REQUEST.REQUEST):
      return true;

    case (REQUEST.SUCCESS):
      return true;

    case (REQUEST.ERROR):
      return true;

    default:
      return false;
  }
}

const RequestDialog = props => {
  const { requestState, requestResult, onRequestBegin } = props

  return (
    <CssDialog
      open={isOpenDialog(requestState)}
    >
      {
        requestState === REQUEST.REQUEST
          ?
          <React.Fragment>
            <div className={styles.dialogLoader}>
              <Loader />
            </div>
          </React.Fragment>
          : null
      }

      {
        requestState === REQUEST.ERROR
          ?
          <DialogContent>
            <DialogTitle>Error: {requestResult.data} </DialogTitle>
            <DialogActions className="errorActions">
            <ButtonReset onClick={onRequestBegin}>
              <PrevButton>Close</PrevButton>
            </ButtonReset>

              <ButtonRequest>
                <NextButton>Retry</NextButton>
              </ButtonRequest>
            </DialogActions>
          </DialogContent>
          : null
      }

      {
        requestState === REQUEST.SUCCESS
          ?
          <DialogContent>
            <DialogTitle>Success</DialogTitle>
            <DialogActions className="successActions">
            <ButtonReset onClick={onRequestBegin}>
              <NextButton>Continue</NextButton>
            </ButtonReset>
            </DialogActions>
          </DialogContent>
          : null
      }
    </CssDialog>
  )
}

export default withAppState(RequestDialog)
