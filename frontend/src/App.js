import React from 'react';
import { Grid } from '@visx/grid';
import { scaleLinear } from '@visx/scale';
import { LinePath } from '@visx/shape';
import { AxisBottom, AxisLeft } from '@visx/axis';

// import { makeStyles } from '@mui/styles';
const data = [
  { x: 1, y: 3 },
  { x: 2, y: 5 },
  { x: 3, y: 2 },
  { x: 4, y: 6 },

];

const width = 500;
const height = 300;
const margin = { top: 20, right: 20, bottom: 50, left: 50 };

// (float * float) list 

// http://yourwebsite.com/test?hello=foo
// =>

//   "{data : [[1, 2], [3, 4]]}"

//const useStyles = makeStyles(() => ({
//  graphContainer: {
//    display: 'flex',
//    justifyContent: 'center',
//  },
//}));

const SimpleLineGraph = () => {
  //const classes = useStyles();

  const xScale = scaleLinear({
    range: [margin.left, width - margin.right],
    domain: [1, 4],
  });

  const yScale = scaleLinear({
    range: [height - margin.bottom, margin.top],
    domain: [0, 6],
  });

  // curve="natural"
  // className={classes.graphContainer}
  return (
    <div>
      <svg width={width} height={height}>
        <Grid
          xScale={xScale}
          yScale={yScale}
          width={width}
          height={height}
          numTicksRows={6}
          numTicksColumns={4}
        />
        <AxisBottom
          scale={xScale}
          top={height - margin.bottom}
          left={margin.left}
          label="X Axis"
        />
        <AxisLeft scale={yScale} top={margin.top} left={margin.left} label="Y Axis" />
        <LinePath
          data={data}
          x={(d) => xScale(d.x)}
          y={(d) => yScale(d.y)}
          stroke="#8884d8"
          strokeWidth={2}
        />
      </svg>
    </div>
  );
};

export default SimpleLineGraph;
