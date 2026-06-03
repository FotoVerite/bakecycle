import React from 'react';
import { render, act } from '@testing-library/react';
import FileExportRefresher from 'components/file-export-refresher';

const props = {
  links: { self: '/file_exports/1' },
  loadingMessage: 'Generating report...',
};

describe('FileExportRefresher', () => {
  let jqXHR;

  beforeEach(() => {
    jest.useFakeTimers();
    jqXHR = {
      done: jest.fn().mockReturnThis(),
      fail: jest.fn().mockReturnThis(),
      abort: jest.fn(),
    };
    global.$ = { get: jest.fn().mockReturnValue(jqXHR) };
  });

  afterEach(() => {
    jest.useRealTimers();
    delete global.$;
  });

  it('shows the loading message on mount', () => {
    const { getByText } = render(<FileExportRefresher {...props} />);
    expect(getByText('Generating report...')).toBeTruthy();
  });

  it('calls $.get on mount', () => {
    render(<FileExportRefresher {...props} />);
    expect(global.$.get).toHaveBeenCalledWith('/file_exports/1');
  });

  it('polls again after 1 second when not ready', () => {
    // simulate a successful but not-ready response
    jqXHR.done.mockImplementation((cb) => {
      // first done: sets state data
      cb({ ready: false, status: '' });
      return jqXHR;
    });

    render(<FileExportRefresher {...props} />);
    expect(global.$.get).toHaveBeenCalledTimes(1);

    act(() => { jest.advanceTimersByTime(1000); });
    expect(global.$.get).toHaveBeenCalledTimes(2);
  });

  it('stops polling on unmount', () => {
    const { unmount } = render(<FileExportRefresher {...props} />);
    unmount();
    act(() => { jest.advanceTimersByTime(5000); });
    // Should not have polled a second time
    expect(global.$.get).toHaveBeenCalledTimes(1);
    expect(jqXHR.abort).toHaveBeenCalled();
  });

  it('polls again after 5 seconds on failure', () => {
    jqXHR.fail.mockImplementation((cb) => {
      cb();
      return jqXHR;
    });

    render(<FileExportRefresher {...props} />);
    expect(global.$.get).toHaveBeenCalledTimes(1);

    act(() => { jest.advanceTimersByTime(5000); });
    expect(global.$.get).toHaveBeenCalledTimes(2);
  });
});
