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
const getDate = (d: data) => {
    return parseDate(d.date)
}
const getStockValue = (d: data) => {
    if (d === undefined) debugger;
    return d.price;
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
        const dateScale = useMemo(
            () => {
                return scaleTime({
                    range: [margin.left, innerWidth + margin.left],
                    domain: extent(stock, getDate),
                });
            },
            [innerWidth, margin.left, stock],
        );


        const stockValueScale = useMemo(
            () =>
                scaleLinear({
                    range: [innerHeight + margin.top, margin.top],
                    domain: [0, (max(stock, getStockValue) || 0) + innerHeight / 3],
                    nice: true,
                }),
            [margin.top, innerHeight, stock],
        );

        const handleTooltip = useCallback(
            (event: React.TouchEvent<SVGRectElement> | React.MouseEvent<SVGRectElement>) => {
                const { x } = localPoint(event) || { x: 0 };
                const x0 = dateScale.invert(x);
                if (!isNaN(x0)) {
                    const index = bisectDate(stock, x0, 1);
                    const d0 = stock[index - 1];
                    const d1 = stock[index];
                    let d = d0;
                    if (d1 && getDate(d1)) {
                        d = x0.valueOf() - getDate(d0).valueOf() > getDate(d1).valueOf() - x0.valueOf() ? d1 : d0;
                    }
                    showTooltip({
                        tooltipData: d,
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
            <div style={{
                background: 'linear-gradient(to bottom, white, gray)',
                height: '100vh',
            }}>
                <Header />

                <pre> {JSON.stringify(initialDatesAndPrices)}</pre>


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
                            data={stock}
                            x={(d) => dateScale(getDate(d)) ?? 0}
                            y={(d) => stockValueScale(getStockValue(d)) ?? 0}
                            yScale={stockValueScale}
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
                                        {`$${getStockValue(tooltipData)}`}
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
                                        {formatDate(getDate(tooltipData))}
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