import {
    useMemo, useCallback, useEffect, useState
} from 'react';
import { AreaClosed, Line, Bar } from '@visx/shape';
import appleStock, { AppleStock } from '@visx/mock-data/lib/mocks/appleStock';
import { curveMonotoneX } from '@visx/curve';
import { GridRows, GridColumns } from '@visx/grid';
import { scaleTime, scaleLinear } from '@visx/scale';
import { withTooltip, Tooltip, TooltipWithBounds, defaultStyles } from '@visx/tooltip';
import { WithTooltipProvidedProps } from '@visx/tooltip/lib/enhancers/withTooltip';
import { localPoint } from '@visx/event';
import { LinearGradient } from '@visx/gradient';
import { max, extent, bisector } from '@visx/vendor/d3-array';
import { timeFormat } from '@visx/vendor/d3-time-format';
import Input from '@mui/joy/Input';
import { Link, useLoaderData } from "react-router-dom";


import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import IconButton from '@mui/material/IconButton';
import MenuIcon from '@mui/icons-material/Menu';
import Header from "./Header";
import Legend from "./Legend";
import { getConfig } from '@testing-library/react';


type total_data = {
    real: data;
    pred: data;
}

type data = {
    date: string;
    price: number;
}

// const stock = appleStock.slice(800);
export const background = '#212529';
export const background2 = '#204051';
// export const accentColor = '#edede9';
// export const accentColorDark = '#6c757d';
export const accentColor = '#edede9';
export const accentColorDark = '#6c757d';
const tooltipStyles = {
    ...defaultStyles,
    background,
    border: '1px solid white',
    color: 'white',
};

const predtooltipStyles = {
    ...defaultStyles,
    background,
    border: '1px solid red',
    color: 'red',
}

// util
const formatDate = timeFormat("%b %d, '%y");


// accessors
const parseDate = (input: string) => {
    const date = new Date(input);
    if (date instanceof Date && !isNaN(date)) return date;
    else throw new Error(`invalid date ${input}`);
}

// const getRealDate = (d: total_data.real) => {
//     return parseDate(d.date)
// }

// const getRealPrice = (d: total_data.real) => {
//     if (d === undefined) debugger;
//     return d.price;
// }

// const getPredDate = (d: total_data.pred) => {
//     return parseDate(d.date)
// }

// const getPredPrice = (d: total_data.pred) => {
//     if (d === undefined) debugger;
//     return d.price;
// }

const getDate = (d: data) => {
    return parseDate(d.date)
}
const getStockValue = (d: data) => {
    if (d === undefined) debugger;
    return d.price;
}

const getRealData = (d: total_data) => {
    return d.real;
}

const getPredData = (d: total_data) => {
    return d.pred;
}
const bisectDate = bisector((d) => parseDate(d.date)).left;

export type AreaProps = {
    width: number;
    height: number;
    margin?: { top: number; right: number; bottom: number; left: number };
};

export async function loader({ params }) {
    console.log(params);
    return params.window;
}

const Bitcoin = withTooltip(
    ({
        width,
        height,
        margin = { top: 0, right: 0, bottom: 0, left: 0 },
        showTooltip,
        hideTooltip,
        tooltipData,
        tooltipTop = 0,
        tooltipLeft = 0,
    }: AreaProps & WithTooltipProvidedProps<TooltipData>) => {

        const innerWidth = 1000;
        const innerHeight = 600;

        const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 })
        const [initialDatesAndPrices, setInitialDatesAndPrices] = useState({ state: 'loading' });
        const [realStock, setRealStock] = useState([]);
        const [predStock, setPredStock] = useState([]);
        useEffect(() => {
            fetch("http://ec2-44-196-240-247.compute-1.amazonaws.com:8181/api/bitcoin")
                .then((response) => {
                    response.json().then((json: array) =>
                        /* CR-someday hlian: You can always slice here if you want */ {
                        setRealStock(json.real_data);
                        setPredStock(json.pred_data);
                    }
                    )
                }).then((data) => {
                    setInitialDatesAndPrices({ state: 'loaded', data })
                }).catch((error) => {
                    setInitialDatesAndPrices({ state: 'error', error: error.message })
                });
            return () => { };
        }, [])
        const dateScale = useMemo(
            () => {
                return scaleTime({
                    range: [margin.left, innerWidth + margin.left],
                    domain: extent(predStock, getDate),
                });
            },
            [innerWidth, margin.left, realStock],
        );


        const stockValueScale = useMemo(
            () =>
                scaleLinear({
                    range: [innerHeight + margin.top, margin.top],
                    domain: [0, (max(predStock, getStockValue) || 0) + innerHeight / 3],
                    nice: true,
                }),
            [margin.top, innerHeight, realStock],
        );


        // const setBoundaries = (dataType) => {
        //     return boundaries({
        //         index: bisectDate(dataType, x0, 1),
        //         d0: dataType[index - 1],
        //         d1: dataType[index],
        //     });

        // };

        // const setPredBoundaries = ()=> {
        //     return boundaries ( {
        //     index : bisectDate(predStock, x0, 1),
        //     d0 : predStock[index - 1],
        //     d1 : predStock[index],
        //     });

        // };


        const handleTooltip = useCallback(
            (event: React.TouchEvent<SVGRectElement> | React.MouseEvent<SVGRectElement>) => {
                const { x } = localPoint(event) || { x: 0 };
                const x0 = dateScale.invert(x);
                if (!isNaN(x0)) {
                    const index = bisectDate(realStock, x0, 1);
                    const d0 = realStock[index - 1];
                    const d1 = realStock[index];
                    let d = d0;
                    if (d1 && getDate(d1)) {
                        d = x0.valueOf() - getDate(d0).valueOf() > getDate(d1).valueOf() - x0.valueOf() ? d1 : d0;
                    }
                    const findex = bisectDate(predStock, x0, 1);
                    const f0 = predStock[findex - 1];
                    const f1 = predStock[findex];
                    let f = f0;
                    if (f1 && getDate(f1)) {
                        f = x0.valueOf() - getDate(f0).valueOf() > getDate(f1).valueOf() - x0.valueOf() ? f1 : f0;
                    }
                    showTooltip({
                        tooltipData: [d, f],
                        tooltipLeft: x,
                        tooltipTop: stockValueScale(getStockValue(d)),
                    });
                }
            },
            [showTooltip, stockValueScale, dateScale],
        );


        useEffect(() => {
            const handleMouseMove = (event) => {
                setMousePosition({ x: event.clientX, y: event.clientY });
            };

            window.addEventListener('mousemove', handleMouseMove);

            return () => {
                window.removeEventListener(
                    'mousemove',
                    handleMouseMove
                );
            };
        }, []);

        return (
            <div>
                <Header />



                <div style={{ display: 'flex', justifyContent: 'center', width: "100%", position: "relative" }}> <div>
                    <svg width={1000} height={600} style={{

                        //    display: 'block', margin: 'auto' 

                    }}>
                        <rect
                            x={0}
                            y={0}
                            width={1000}
                            height={600}
                            fill="url(#area-background-gradient)"
                            rx={14}
                        />
                        <LinearGradient id="area-background-gradient" from={background} to={background2} />
                        <LinearGradient id="area-gradient" from={accentColor} to={accentColor} toOpacity={0.1} />
                        <LinearGradient id="stroke-gradient" from="#fc3003" to="#fc3003" toOpacity={0.1} />
                        <LinearGradient id="new-area-gradient" from="#f8f9fa" fromOpacity={0.0} to="#f8f9fa" toOpacity={0.0} />
                        <GridRows
                            left={margin.left}
                            scale={stockValueScale}
                            width={innerWidth}
                            strokeDasharray="1,3"
                            stroke={accentColor}
                            strokeOpacity={0}
                            pointerEvents="none"
                        />
                        <GridColumns
                            top={margin.top}
                            scale={dateScale}
                            height={innerHeight}
                            strokeDasharray="1,3"
                            stroke={accentColor}
                            strokeOpacity={0.2}
                            pointerEvents="none"
                        />
                        <AreaClosed
                            data={realStock}
                            x={(d) => dateScale(getDate(d)) ?? 0}
                            y={(d) => stockValueScale(getStockValue(d)) ?? 0}
                            yScale={stockValueScale}
                            strokeWidth={1}
                            stroke="url(#area-gradient)"
                            fill="url(#area-gradient)"
                            curve={curveMonotoneX}
                        />
                        <AreaClosed
                            data={predStock}
                            x={(d) => dateScale(getDate(d)) ?? 0}
                            y={(d) => stockValueScale(getStockValue(d)) ?? 0}
                            yScale={stockValueScale}
                            strokeWidth={1}
                            stroke="url(#stroke-gradient)"
                            fill="url(#new-area-gradient)"
                            curve={curveMonotoneX}
                        />
                        <Bar
                            x={margin.left}
                            y={margin.top}
                            width={innerWidth}
                            height={innerHeight}
                            fill="transparent"
                            rx={14}
                            onTouchStart={handleTooltip}
                            onTouchMove={handleTooltip}
                            onMouseMove={handleTooltip}
                            onMouseLeave={() => hideTooltip()}
                        />
                        {tooltipData && (
                            <g>
                                <Line
                                    from={{ x: tooltipLeft, y: margin.top }}
                                    to={{ x: tooltipLeft, y: innerHeight + margin.top }}
                                    stroke={accentColorDark}
                                    strokeWidth={2}
                                    pointerEvents="none"
                                    strokeDasharray="5,2"
                                />
                                <circle
                                    cx={tooltipLeft}
                                    cy={tooltipTop + 1}
                                    r={4}
                                    fill="black"
                                    fillOpacity={0.1}
                                    stroke="black"
                                    strokeOpacity={0.1}
                                    strokeWidth={2}
                                    pointerEvents="none"
                                />
                                <circle
                                    cx={tooltipLeft}
                                    cy={tooltipTop}
                                    r={4}
                                    fill={accentColorDark}
                                    stroke="white"
                                    strokeWidth={2}
                                    pointerEvents="none"
                                />


                            </g>
                        )}
                    </svg>
                    <div style={{ display: "flex", justifyContent: "center" }}>
                        {
                            (tooltipData) && (
                                <div>
                                    <TooltipWithBounds
                                        key={Math.random()}
                                        top={tooltipTop + 20}
                                        left={mousePosition.x}
                                        style={tooltipStyles}
                                    >
                                        {`$${getStockValue(tooltipData[0])}`}
                                    </TooltipWithBounds>
                                    <TooltipWithBounds
                                        key={Math.random()}
                                        top={tooltipTop - 30}
                                        left={mousePosition.x}
                                        style={predtooltipStyles}
                                    >
                                        {`$${getStockValue(tooltipData[1])}`}
                                    </TooltipWithBounds>

                                    <Tooltip
                                        top={innerHeight + margin.top - 14}
                                        left={mousePosition.x}
                                        style={{
                                            ...defaultStyles,
                                            minWidth: 72,
                                            textAlign: 'center',
                                            transform: 'translateX(-50%)',
                                        }}
                                    >
                                        {formatDate(getDate(tooltipData[0]))}
                                    </Tooltip>
                                    <Tooltip
                                        top={innerHeight + margin.top + 14}
                                        left={mousePosition.x}
                                        style={{
                                            ...defaultStyles,
                                            minWidth: 72,
                                            textAlign: 'center',
                                            transform: 'translateX(-50%)',
                                            color: 'red'
                                        }}
                                    >
                                        {formatDate(getDate(tooltipData[1]))}
                                    </Tooltip>
                                </div>
                            )


                        }
                    </div>


                </div>



                </div >

                {/* {tooltipData && (
                    <Box display="flex" justifyContent="center" mt={2}>
                        <Input type="text" placeholder="Enter text here" />
                    </Box>
                )} */}

            </div>
        );
    },
);

export const bitcoinLoader = async ({ params }) => {
    return { bitcoinWindow: params.window }
}

export default Bitcoin;


