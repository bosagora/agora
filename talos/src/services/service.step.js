export const isCurrentStep = (currentIndex, stepIndex) => {
  return currentIndex === stepIndex
}

const currentStepClassName = (currentIndex, stepIndex) => {
  return isCurrentStep(currentIndex, stepIndex)
    ? " IsCurrent"
    : " IsHidden"
}

const animateDirectionClassName = (prevIndex, currentIndex, stepIndex) => {
  if (prevIndex === currentIndex - 1 && isCurrentStep(currentIndex, stepIndex))
    return " ShowNext"

  else if (prevIndex === currentIndex + 1 && isCurrentStep(currentIndex, stepIndex))
    return " ShowPrev"

  else if (currentIndex + 1 === stepIndex)
    return " HidePrev"

  else if (currentIndex - 1 === stepIndex)
    return " HideNext"

  else
    return ""
}

export const buildStepClassName = ({ params: { currentIndex, prevStepIndex, stepIndex } }) => {
  const string = animateDirectionClassName(prevStepIndex, currentIndex, stepIndex) + currentStepClassName(currentIndex, stepIndex)

  return string
}
