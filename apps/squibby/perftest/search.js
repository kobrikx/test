import http from 'k6/http';
import { sleep } from 'k6';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";

export const options = {
  // A number specifying the number of VUs to run concurrently.
  vus: 50,
  // A string specifying the total duration of the test run.
  duration: '60s',
}

export default function () {
  const vu = `${__VU}`;
  const params = { headers: { 'Content-Type': 'application/json', "Query": vu} };
  http.request('POST',`http://${__ENV.API_URL}`, params);
  // This need to show what VU is working now (could be removed)
  console.log(vu);
  sleep(1);
}
export function handleSummary(data) {
  return {
    "summary.html": htmlReport(data),
  };
}
