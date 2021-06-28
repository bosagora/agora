import { connect } from 'react-redux'
import get from 'lodash/get';

import {
  changeAdministrativeInterfaceItems as onChangeAdministrativeInterfaceItems,
  setValidAdministrativeInterfaceItem as onSetValidAdministrativeInterfaceItem,
} from './Action'

const mapStateToProps = (state) => ({
  administrativeInterface: {
    stepItems: get(state, ['administrativeInterface', 'stepItems'], {}),
  },
});

const mapDispatchToProps = {
  onChangeAdministrativeInterfaceItems,
  onSetValidAdministrativeInterfaceItem,
}

export const withAdministrativeInterface = Component => connect(mapStateToProps, mapDispatchToProps)(Component)
