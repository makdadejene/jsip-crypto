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


// import Ethereum from "./Ethereum";
// import XRP from ".Xrp";

// let getCoin = {
//     date : 
//     prices :
// }

type total_data = {
    real: data;
    pred: data;
}

type data = {
    date: string;
    price: number;
}

// const stock = appleStock.slice(800);
export const background = '#3b6978';
export const background2 = '#204051';
export const accentColor = '#edffea';
export const accentColorDark = '#75daad';
const tooltipStyles = {
    ...defaultStyles,
    background,
    border: '1px solid white',
    color: 'white',
};

// util
const formatDate = timeFormat("%b %d, '%y");


// accessors
const parseDate = (input: string) => {
    const date = new Date(input);
    if (date instanceof Date && !isNaN(date)) return date;
    else throw new Error(`invalid date ${input}`);
}

const getRealDate = (d: total_data.real) => {
    return parseDate(d.date)
}
const getRealPrice = (d: total_data.real) => {
    if (d === undefined) debugger;
    return d.price;
}
const getPredDate = (d: total_data.pred) => {
    return parseDate(d.date)
}
const getPredPrice = (d: total_data.pred) => {
    if (d === undefined) debugger;
    return d.price;
}

// const getDate = (d: data) => {
//     return parseDate(d.date)
// }
// const getStockValue = (d: data) => {
//     if (d === undefined) debugger;
//     return d.price;
// }
// const getRealData = (d: total_data) => {
//     return d.real;
// }
// const getPredData = (d: total_data) => {
//     return d.pred;
// }


const bisectRealDate = bisector((d) => getRealDate(d.date)).left;
const bisectPredDate = bisector((d) => getPredDate(d.date)).left;

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
        margin = { top: 0, right: 1, bottom: 0, left: 1 },
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
        const [stock, setStock] = useState([]);
        useEffect(() => {
            fetch("http://ec2-44-196-240-247.compute-1.amazonaws.com:8181/api/bitcoin/30")
                .then((response) => {
                    response.json().then((json: array) =>
                        /* CR-someday hlian: You can always slice here if you want */
                        setStock(json)
                    )
                }).then((data) => {
                    setInitialDatesAndPrices({ state: 'loaded', data })
                }).catch((error) => {
                    setInitialDatesAndPrices({ state: 'error', error: error.message })
                });
            return () => { };
        }, [])

        const dateRealScale = useMemo(
            () => {
                return scaleTime({
                    range: [margin.left, innerWidth + margin.left],
                    domain: extent(stock, getRealDate),
                });
            },
            [innerWidth, margin.left, stock],
        );

        const datePredScale = useMemo(
            () => {
                return scaleTime({
                    range: [margin.left, innerWidth + margin.left],
                    domain: extent(stock, getPredDate),
                });
            },
            [innerWidth, margin.left, stock],
        );


        const stockRealValueScale = useMemo(
            () =>
                scaleLinear({
                    range: [innerHeight + margin.top, margin.top],
                    domain: [0, (max(stock, getRealPrice) || 0) + innerHeight / 3],
                    nice: true,
                }),
            [margin.top, innerHeight, stock],
        );

        const stockPredValueScale = useMemo(
            () =>
                scaleLinear({
                    range: [innerHeight + margin.top, margin.top],
                    domain: [0, (max(stock, getPredPrice) || 0) + innerHeight / 3],
                    nice: true,
                }),
            [margin.top, innerHeight, stock],
        );

        const handleRealTooltip = useCallback(
            (event: React.TouchEvent<SVGRectElement> | React.MouseEvent<SVGRectElement>) => {
                const { x } = localPoint(event) || { x: 0 };
                const x0 = dateRealScale.invert(x);
                if (!isNaN(x0)) {
                    const index = bisectRealDate(stock, x0, 1);
                    const d0 = stock[index - 1];
                    const d1 = stock[index];
                    let d = d0;
                    if (d1 && getRealDate(d1)) {
                        d = x0.valueOf() - getRealDate(d0).valueOf() > getRealDate(d1).valueOf() - x0.valueOf() ? d1 : d0;
                    }
                    showTooltip({
                        tooltipData: d,
                        tooltipLeft: x,
                        tooltipTop: stockRealValueScale(getRealPrice(d)),
                    });
                }
            },
            [showTooltip, stockRealValueScale, dateRealScale],
        );

        const handlePredTooltip = useCallback(
            (event: React.TouchEvent<SVGRectElement> | React.MouseEvent<SVGRectElement>) => {
                const { x } = localPoint(event) || { x: 0 };
                const x0 = datePredScale.invert(x);
                if (!isNaN(x0)) {
                    const index = bisectPredDate(stock, x0, 1);
                    const d0 = stock[index - 1];
                    const d1 = stock[index];
                    let d = d0;
                    if (d1 && getPredDate(d1)) {
                        d = x0.valueOf() - getPredDate(d0).valueOf() > getPredDate(d1).valueOf() - x0.valueOf() ? d1 : d0;
                    }
                    showTooltip({
                        tooltipData: d,
                        tooltipLeft: x,
                        tooltipTop: stockPredValueScale(getPredPrice(d)),
                    });
                }
            },
            [showTooltip, stockPredValueScale, datePredScale],
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
            <div style={{
                background: 'linear-gradient(to bottom, white, gray)',
                height: '100vh',
            }}>
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
                        <GridRows
                            left={margin.left}
                            scale={stockRealValueScale}
                            width={innerWidth}
                            strokeDasharray="1,3"
                            stroke={accentColor}
                            strokeOpacity={0}
                            pointerEvents="none"
                        />
                        <GridColumns
                            top={margin.top}
                            scale={dateRealScale}
                            height={innerHeight}
                            strokeDasharray="1,3"
                            stroke={accentColor}
                            strokeOpacity={0.2}
                            pointerEvents="none"
                        />
                        <AreaClosed
                            data={stock}
                            x={(d) => dateRealScale(getRealDate(d)) ?? 0}
                            y={(d) => stockRealValueScale(getRealPrice(d)) ?? 0}
                            yScale={stockRealValueScale}
                            strokeWidth={1}
                            stroke="url(#area-gradient)"
                            fill="url(#area-gradient)"
                            curve={curveMonotoneX}
                        />
                        <AreaClosed
                            data={stock}
                            x={(d) => datePredScale(getPredDate(d)) ?? 0}
                            y={(d) => stockPredValueScale(getPredPrice(d)) ?? 0}
                            yScale={stockPredValueScale}
                            strokeWidth={1}
                            stroke="url(#area-gradient)"
                            fill="url(#area-gradient)"
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
                                        top={tooltipTop - 12}
                                        left={mousePosition.x}
                                        style={tooltipStyles}
                                    >
                                        {`$${getRealPrice(tooltipData)}`}
                                    </TooltipWithBounds>

                                    <TooltipWithBounds
                                        key={Math.random()}
                                        top={tooltipTop - 12}
                                        left={mousePosition.x}
                                        style={tooltipStyles}
                                    >
                                        {`$${getPredPrice(tooltipData)}`}
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
                                        {formatDate(getRealDate(tooltipData))}
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