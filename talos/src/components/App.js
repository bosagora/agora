import React from 'react';

import Preview from "./preview/preview"
import StepWrapper from "./steps/stepWrapper"

import './app.scss'

const App = () => {
  return (
    <div>
      <Preview />

      <StepWrapper />
    </div>
  )
}

export default App;
