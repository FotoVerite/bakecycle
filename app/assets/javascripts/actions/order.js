import * as types from '../constants/action-types';
import mapValues from 'lodash.mapvalues';
import isFinite from 'lodash.isfinite';
import moment from 'moment';

export function updateOrder(data) {
  data = Object.assign({}, data);
  return {
    type: types.ORDER_UPDATE,
    data,
  };
}

export function validateOrderStartDate(data) {
  //first we need to parse the kickoff
  const errors = {errors: {start_date: validateLeadTime(data), end_date: validateEndTime(data) }};
  return {
    type: types.ORDER_VALIDATE,
    data: errors,
  };
}

function validateLeadTime(data) {
  if(data.id !== null && 'orderType' === 'standing' ) {
    return [];
  }
  let kickoff = moment.parseZone(data.kickoff_time);
  // because kickoff_time is a date we parse it for the hour and utc offset
  const offset = kickoff.utcOffset();
  const kickoffHour = kickoff.hour();
  //we find out if kickoff time has past for today
  kickoff = moment().hour(kickoffHour).utcOffset(offset);
  const isBeforeKickoff = moment().isBefore(kickoff);
  //now we set maximum start date +1 if kickoff has already happened
  let neededLeadDays = 0;
  if(!(isBeforeKickoff)) {
    neededLeadDays= neededLeadDays + 1;
  }
  neededLeadDays = neededLeadDays + data.totalLeadDays;
  const mustStartAfter = moment().add(neededLeadDays, 'days').startOf('day');
  const hasleadTimeError = moment(data.startDate).isBefore(mustStartAfter);
  if (hasleadTimeError) {
    let msg = kickoff ? 'There are not enough lead days, it\' after kickoff.' : 'There are not enough lead days.';
    msg = msg + ' The earliest date would be '  + mustStartAfter.format('L');
    return [msg];
  } else {
    return [];
  }
}

function validateEndTime(data) {
  if(data.endDate === undefined || data.startDate === undefined) {
    return [];
  }
  if(moment(data.startDate).isAfter(moment(data.endDate))) {
    return ['The end date cannot be before the start date'];
  }
  else {
    return [];
  }
}

export function updateOrderItem(orderItem, data) {
  data = mapValues(data, (value, key) => {
    if(typeof value === 'string' && value !== '') {
      value = Number(value);
      if (!isFinite(value)) {
        return orderItem[key];
      }
    }
    return value;
  });
  return {
    type: types.ORDER_ITEM_UPDATE,
    orderItem,
    data,
  };
}

export function addOrderItem(data) {
  data = data || {};
  return {
    type: types.ORDER_ITEM_ADD,
    data,
  };
}

export function removeOrderItem(data) {
  return {
    type: types.ORDER_ITEM_REMOVE,
    data,
  };
}

export function toggleDestroy(data) {
  if (data.id) {
    return updateOrderItem(data, { destroy: !data.destroy});
  } else {
    return removeOrderItem(data);
  }
}
