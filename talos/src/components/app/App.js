import React from 'react';

import Step from "../Step"
import Preview from "../preview/preview"
import StepWrapper from "../steps/stepWrapper"

import './app.scss'

const App = () => {
    return (
        <div>
            <Step navigationIndex={0}>
                <Preview />
            </Step>

            <StepWrapper />
        </div>
    )
}

export default App;
