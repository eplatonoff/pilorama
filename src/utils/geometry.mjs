export function mouseAngle(mousePoint, centerPoint) {
    const angle =
                Math.atan(
                    Math.abs(mousePoint.x - centerPoint.x) /
                    Math.abs(mousePoint.y - centerPoint.y)
                    )
                * (180 / Math.PI);

    if (mousePoint.x >= centerPoint.x)
        return mousePoint.y <= centerPoint.y ? angle : 180 - angle;
    else
        return mousePoint.y <= centerPoint.y ? 360 - angle : 180 + angle;
}
