export function mouseAngle(mousePoint, centerPoint) {
    const angle =
        Math.atan(
            Math.abs(mousePoint.x - centerPoint.x) /
            Math.abs(mousePoint.y - centerPoint.y)
        )
        * (180 / Math.PI);

    if (mousePoint.x >= centerPoint.x)
        return mousePoint.y <= centerPoint.y ? precision(angle) : 180 - precision(angle);
    else
        return mousePoint.y <= centerPoint.y ? 360 - precision(angle) : 180 + precision(angle);
}


function modulo(num, denom) {
    const res = num % denom;
    return res >= 0 ? res : res + denom;
}

function precision(num) {
    var precision = 6
    var y = Math.abs(num) + precision / 2;
    y = y - y % precision;
    return num < 0 ? -y : y
}


export function lessDelta(newAngle, prevAngle) {
    const delta1 = modulo(newAngle - prevAngle, 360);
    const delta2 = modulo(prevAngle - newAngle, 360);

    let delta = delta1 < delta2 ? delta1 : delta2;

    if (modulo(prevAngle + delta, 360) !== newAngle) {
        delta = delta * (-1);
    }

    return precision(delta);
}
